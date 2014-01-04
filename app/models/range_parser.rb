class RangeParser
  attr_reader :range_str, :last_error
  
  def initialize range_str, sort: true
    self.range_str = range_str
    @sort = sort
  end
  
  def range_str=( str )
    @range_str = str
    @parses = nil
    @last_error = nil
    parses?
  end
  
  def section_strings
    # Clean it up and get it ready for parsing
    @range_str.to_s.split( "," ).reject(&:blank?)
  end
  
  def sections
    section_strings.map{ | section_str | Section.new( section_str ) }
  end
  
  def parses?
    return @parses unless @parses.nil?
    
    # One of the sections will throw an exception if unparsable:
    sections()
    
    @parses = true
  rescue => e
    @last_error = e.message
    @parses = false
  end
  
  def buildings fill_gaps: false
    all_buildings = sections.flat_map(&:buildings)
    
    grouped = all_buildings.group_by(&:building)
    
    buildings = grouped.map do |building, buildings|
      other_buildings = buildings.drop( 1 )
      buildings.first.merge( other_buildings )
    end
    
    fill_gaps( buildings ) if fill_gaps

    buildings.sort! if @sort
    
    buildings 
  end
  
  def fill_gaps buildings
    buildings.concat missing_buildings_by_entrances( buildings )
    buildings.concat missing_buildings_by_numbers( buildings )
  end
  private :fill_gaps

  def missing_buildings_by_entrances buildings
    missing_blds = []
    with_entrances = buildings.select{ |bld| bld.entrance? }
    by_number = with_entrances.group_by(&:number)
    by_number.each do |number, buildings|
      entrances = buildings.map(&:entrance)
      highest_entrance = entrances.max
      missing_entrances = [*"a"..highest_entrance] - entrances
      missing_entrances.each do |entrance|
        missing_blds << Building.new( number, entrance )
      end
    end
    missing_blds
  end
  # private :missing_buildings_by_entrances
  
  def missing_buildings_by_numbers buildings
    existing_numbers = buildings.map(&:number)
    all_numbers = [*1..buildings.max.number]
    missing_numbers = all_numbers - existing_numbers
    missing_numbers.map{ |n| Building.new( n ) }
  end
  private :missing_buildings_by_numbers
end


class RangeParser
  class Section
    attr_reader :str
    
    def initialize str
      @str = str.strip # or .dup
      validate!
    end
    
    def low
      str.split( "-" )[0].to_i if range?
    end
    
    def high
      str.split( "-" )[1].to_i if range?
    end
    
    def flat
      n = str.split( "/" )[1]
      n.to_i if n
    end
    alias :flat? :flat
    
    def entrance
      # unless even_odd?
        str.match( /\d+([a-zA-Z])/ ).try(:[],1).try(:downcase)
      # end
    end
    alias :entrance? :entrance
    
    def number
      if building?
        n = str.match( /(\d+)/ ).try( :[], 1 )
        n.to_i if n
      end
    end
    
    # def number_entrance_flat
    #   if building?
    #     "#{number}#{entrance}#{ '/' + flat.to_s if flat? }"
    #   end
    # end
    
    def building?
      not range?
    end
    
    def building
      bld = Building.new( number, entrance )
      flat ? bld.covered_flats << flat : bld.all_covered = true
      bld
    end
    
    def buildings
      return [ building ] if building?
      
      ar = *low..high
      ar.select!{ |n| n.send "#{even_odd}?" } if even_odd?
      
      ar.map{ |e| Building.new( e ) }
    end
    
    # Returns "even", "odd", or nil.
    def even_odd
      str.match( /.*(even|odd)/i ).try( :[], 1 ).try( :downcase )
    end
    alias :even_odd? :even_odd
    
    def range?
      str.include?( "-" )
    end

  private
    def validate!
      case
      when ( range? and ( flat? or entrance? ) )
        raise "Cannot combine range with flat or entrance (#{ @str })"
      when ( even_odd? and ( flat? or entrance? ) )
        raise "Cannot combine even/odd with flat or entrance (#{ @str })"
      when ( range? and low >= high )
        raise "Range should go from low to high number (#{ @str })"
      when ( number.nil? and not range? )
        raise "No building number (#{ @str })"
      when ( range? and low <= 0 )
        raise "Cannot have numbers lower than 1 in range (#{ @str })"
      when ( building? and number <= 0 )
        raise "Cannot have numbers lower than 1 (#{ @str })"
      when @str.blank?
        raise ( "Blank string (#{ @str })" )
      end
      # parses "a/7" "/7"
    end
  end
  # end of class Section
end


class RangeParser
  class Building
    attr_reader :number, :entrance
    attr_accessor :all_covered
    alias :all_covered? :all_covered
    
    def initialize number, entrance = nil
      @number = number
      @entrance = entrance
      @covered_flats = SortedSet.new
    end
    
    def entrance?
      not entrance.blank?
    end
    
    # Returns number of flats, or nil.
    def highest_flat
      [@highest_flat, @covered_flats.max].compact.max
    end
    
    def highest_flat=( num )
      @highest_flat = [@highest_flat, num].compact.max
    end
    
    def covered_flats
      if all_covered?
        @covered_flats = SortedSet.new( all_flats )
      end
      
      @covered_flats
    end
    
    def uncovered_flats
      all_flats - covered_flats.to_a
    end
    
    def all_flats
      [*1..highest_flat.to_i]
    end
    
    def building
      "#{number}#{entrance}"
    end
    
    def to_s
      "#{building} (#{covered_flats.to_a})"
    end
    
    def ==( other )
      building==other.building
    end
    
    def <=>( other )
      [number, entrance.to_s] <=> [other.number, other.entrance.to_s]
    end
    
    def merge buildings
      other_flats = buildings.flat_map{ |bld| bld.covered_flats.to_a }
      covered_flats.merge other_flats
      @all_covered = buildings.select(&:all_covered).any?
      self
    end
  end
  # end of class Building
end
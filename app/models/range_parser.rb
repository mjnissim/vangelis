class RangeParser
  attr_reader :range_str, :last_error
  
  def initialize range_str, sort: true
    self.range_str = range_str
    @sort = sort
  end
  
  def range_str=( str )
    @range_str = str.strip.dup
    @parses = nil
    @last_error = nil
    parses?
  end
  
  # Clean the string up and get it ready for parsing.
  def section_strings
    # Insert commas before whitespace-digit sequences
    # Makes things that look like this:
    # "1 2/3a 3-5 even 6 4-7 odd 8"
    # To look like this:
    # "1, 2, 3-5 even, 6, 4-7 odd, 8"
    @range_str.gsub! /(?<seq>\s\d)/i, ',\k<seq>'
    
    @range_str.split( "," ).reject(&:blank?)
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
      n = str.split( "/" )[1].to_i
      n unless n.zero?
    end
    alias :flat? :flat
    
    def entrance
      str.match( /\d+([a-zA-Z])/ ).try(:[],1).try(:downcase)
    end
    alias :entrance? :entrance
    
    def number
      if building?
        n = str.split("/").first.to_i
        n unless n.zero?
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
        raise "Blank string (#{ @str })"
      when @str.split( " " ).size > 2
        raise "Malformed (#{ @str })"
      when ( @str.split( " " ).many? and
         not @str.split( " " )[1].match( /(even|odd)/i ) )
        raise "Unnecessary spaces (#{ @str })"
      when ( building? and not @str.match( /^\b*\d+(?:[a-z])?(\/\d+)?\b*$/i ) )
        # See it in action: http://rubular.com/r/mF630y9fzeend
        raise "Malformed building (#{ @str })"
      when ( range? and not @str.match( /^\b*\d+-\d+\b*(?:\s*(even|odd))?$/i ) )
        # See it in action: http://rubular.com/r/KHmnVsnaXq
        raise "Malformed range (#{ @str })"
      end
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
      "#{building} (#{covered_flats.to_a.join(', ')})"
    end
    
    def ==( other )
      building==other.building
    end
    
    def <=>( other )
      a = [number, entrance.to_s]
      a << covered_flats.first.to_i
      b = [other.number, other.entrance.to_s]
      b << other.covered_flats.first.to_i
      a <=> b 
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
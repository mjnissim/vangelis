class BuildingRange
  attr_reader :sort, :range_str, :last_error, :fill_gaps,
              :splat, :switch_markings, :street
  
  def initialize range_str, street: nil, fill_gaps: false
    self.range_str = range_str
    @sort = true
    @street = street
    @fill_gaps = fill_gaps
  end
  
  def range_str=( str )
    @range_str = str.strip.dup
    reset
  end
  
  def sort= value
    @sort = value
    reset
  end
  
  def fill_gaps= value
    @fill_gaps = value
    reset
  end
  
  def splat= value
    @splat = value
    reset
  end
  
  def switch_markings= value
    @switch_markings = value
    reset
  end
  
  def reset
    @last_error = nil
    @buildings = nil
  end
  private :reset
  
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
    section_strings.map do | section_str |
      Section.new( section_str, street: @street )
    end
  end
  
  def parses?
    # One of the sections will throw an exception if unparsable:
    buildings()
    true
    
  rescue => e
    @last_error = e.message
    false
  end
  
  def buildings
    return @buildings if @buildings
    
    prepare_buildings
    @buildings.dup
  end
  alias :to_a :buildings
  
  # Sorts buildings without regard to whether 'sort' is set to true or false.
  def to_str even_odd: false
    cs = ConciseString.new( buildings, even_odd: even_odd ).str
  end
  
  def [] (building)
    return buildings.find{ |bld| bld == building } if building.is_a? Building
    buildings.find{ |bld| bld.building == building }
  end
  
  def ungrouped_buildings
    sections.flat_map(&:buildings)
  end
  
  private
  
    def prepare_buildings
      @buildings = grouped_buildings
      fill_building_gaps() if fill_gaps
      switch_flat_markings() if switch_markings
      splat_flats() if splat
      @buildings.sort! if @sort
    end
  
    def grouped_buildings
      grouped = ungrouped_buildings.group_by(&:building)
      grouped.map do |building, buildings|
        other_buildings = buildings.drop( 1 )
        buildings.first.merge( other_buildings )
      end
    end
    
    def fill_building_gaps
      fill_entrances
      fill_numbers
    end
  
    def fill_entrances
      missing_blds = []
      by_number = buildings_with_entrances.group_by(&:number)
      by_number.each do |number, buildings|
        entrances = buildings.map(&:entrance)
        highest_entrance = entrances.max
        missing_entrances = [*"a"..highest_entrance] - entrances
        missing_entrances.each do |entrance|
          @buildings << Building.new( "#{number}#{entrance}", street: @street )
        end
      end
    end
  
    def fill_numbers
      missing_numbers = all_possible_building_numbers - building_numbers
      missing_blds = missing_numbers.map do |number|
        Building.new( number.to_s, street: @street )
      end
      @buildings.concat missing_blds
    end
    
    def building_numbers
      @buildings.map(&:number)
    end
    
    def all_possible_building_numbers
      [*1..@buildings.max.number]
    end
    
    def buildings_with_entrances
      @buildings.select(&:entrance?)
    end
  
    def splat_flats
      @buildings.map!(&:splat).flatten!
    end
  
    def switch_flat_markings
      @buildings.each &:switch_markings
    end
end


class BuildingRange
  class Section
    attr_reader :str, :street
    
    def initialize str, street: street
      @str = str.strip # or .dup
      @street = street
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
    
    def building?
      not range?
    end
    
    def building
      bld = Building.new( "#{number}#{entrance}", street: @street )
      flat ? bld.marked_flats << flat : bld.all_marked = true
      bld
    end
    
    def buildings
      return [ building ] if building?
      
      ar = *low..high
      ar.select!{ |n| n.send "#{even_odd}?" } if even_odd?
      
      ar.map{ |num| Building.new( num.to_s, street: @street ) }
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


class BuildingRange
  class Building
    attr_reader :number, :entrance, :street
    attr_accessor :all_marked
    alias :all_marked? :all_marked
    
    def initialize str, street: street
      @street = street
      @marked_flats = SortedSet.new
      initialize_from_string str
    end
    
    def initialize_from_string str
      sec = Section.new( str )
      raise "Cannot initialize building from #{str}" unless sec.building?
      
      @number = sec.number
      @entrance = sec.entrance
      @marked_flats << sec.flat if sec.flat?
    end
    private :initialize_from_string
    
    def entrance?
      not entrance.blank?
    end
    
    # Returns number of flats, or nil.
    def highest_flat
      from_street = @street.buildings[self].try( :highest_flat ) if @street

      [from_street, @highest_flat, @marked_flats.max].compact.max
    end
    
    def highest_flat=( num )
      @highest_flat = [@highest_flat, num].compact.max
    end
    
    def flats?
      highest_flat.present?
    end
    
    def marked_flats
      if all_marked?
        @marked_flats = SortedSet.new( all_flats )
      end
      
      @marked_flats
    end
    
    def unmarked_flats
      all_flats - marked_flats.to_a
    end
    
    def all_flats
      [*1..highest_flat.to_i]
    end
    
    def building
      "#{number}#{entrance}"
    end
    
    def to_s
      return "#{building}/#{marked_flats.first}" if marked_flats.one?
      
      flats = " (#{marked_flats.to_a.join(', ')})" if marked_flats.any?
      "#{building}#{flats}"
    end
    
    def ==( other )
      building==other.building
    end
    
    def <=>( other )
      a, b = [self, other].map do |bld|
        [ bld.number, bld.entrance.to_s ] + [ bld.marked_flats.first.to_i ]
      end

      a <=> b 
    end
    
    def merge buildings
      other_flats = buildings.flat_map{ |bld| bld.marked_flats.to_a }
      marked_flats.merge other_flats
      @all_marked = buildings.select(&:all_marked).any?
      
      self
    end
    
    def splat
      return [self] if marked_flats.none?
      
      marked_flats.map do |flat|
        Building.new( "#{building}/#{flat}", street: @street )
      end
    end
    
    def switch_markings
      # The next line seems unnecessary, but if highest_flat is taken from
      # highest marked flat, switching its status could result in a lower
      # highest_flat. This ensures it remains.
      self.highest_flat = highest_flat
      
      marked_flats.replace unmarked_flats
    end
  end
  # end of class Building
end

class BuildingRange
  class ConciseString
    def initialize buildings, even_odd: false
      @buildings = buildings
      @bld_arrays = []
      even_odd ? set_even_odd : set_regular
    end
    
    def set_regular
      @increment = 1
      @buildings = @buildings.sort
    end
    
    def set_even_odd
      @increment = 2
      @buildings = @buildings.sort_by{ |bld| [bld.number.odd? ? 0 : 1, bld] }
    end
    
    def str
      @str = @str || build_string
    end
    
    def build_string
      process_buildings
      arrays_to_strings.join( ", ")
    end
    
    def process_buildings
      @buildings.each_with_index do |bld, i|
        @bld, @i = bld, i
        process
      end
    end
    
    def process
      case
      when flats_or_entrance?( @bld )
        @bld_arrays << [@bld]
      when next_in_range?
        @bld_arrays.last << @bld
      else
        @bld_arrays << [@bld]
      end
    end
    
    def next_in_range?
      return unless last_bld
      return if flats_or_entrance?( last_bld )
        
      last_bld.number + @increment == @bld.number
    end
    
    def last_bld
      @bld_arrays.last.try(:last)
    end
    
    def flats_or_entrance? bld
      bld.flats? or bld.entrance?
    end
    
    def arrays_to_strings
      @bld_arrays.map do |ar|
        s = "#{ar.first}"
        s << ( ar.many? ? "-#{ ar.last.number }" : '')
      end
    end
  end
end
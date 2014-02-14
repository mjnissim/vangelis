class Buildings
  attr_reader :sort, :str, :last_error, :fill_gaps,
              :splat, :switch_markings, :street
  alias :switch_markings? :switch_markings
  
  def initialize str = nil, street: nil, fill_gaps: false
    self.str = str
    @sort = true
    @street = street
    @fill_gaps = fill_gaps
  end
  
  def str=( str )
    @str = str.to_s.strip #.dup
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
    @str.gsub! /(?<seq>\s\d)/i, ',\k<seq>'
    
    @str.split( "," ).reject(&:blank?)
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
  
  def buildings copy: false
    prepare_buildings if @buildings.nil?
    
    return Marshal.load( Marshal.dump( @buildings ) ) if copy
    
    @buildings
  end
  alias :to_a :buildings
  
  # Produces concise representation string.
  # Sorts buildings without regard to whether 'sort' is set to true or false.
  def to_str even_odd: false, show_flats: false
    ConciseString.new( buildings, even_odd: even_odd,
      show_flats: show_flats ).str
  end
  
  def [] ( building )
    return buildings.find{ |bld| bld == building } if building.is_a? Building
    buildings.find{ |bld| bld.address == building }
  end
  
  def residence_count
    buildings.map do |bld|
      bld.flats? ? bld.marked_flats.count : 1
    end.sum
  end
  
  def flat_count
    buildings.map { |bld| bld.marked_flats.count }.sum
  end
  
  def except_last
    buildings[0...-1]
  end
  
  def last
    buildings.last
  end
  
  private
  
    def prepare_buildings
      @buildings = grouped_buildings
      fill_building_gaps() if fill_gaps
      switch_building_markings() if switch_markings
      splat_flats() if splat
      @buildings.sort! if @sort
    end
  
    def grouped_buildings
      grouped = ungrouped_buildings.group_by(&:address)
      grouped.map do |address, blds|
        other_blds = blds.drop( 1 )
        blds.first.merge( other_blds )
        blds.first
      end
    end
    
    def ungrouped_buildings
      sections.flat_map(&:buildings)
    end

    def fill_building_gaps
      BuildingsFiller.new( @buildings, @street )
    end
  
    def splat_flats
      @buildings.map!(&:splat).flatten!
    end
  
    def switch_building_markings
      @buildings.each &:switch_markings
      drop_entirely_marked_buildings
    end
    
    def drop_entirely_marked_buildings
      @buildings.reject!(&:all_marked?)
    end
end


class Buildings
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
      flat = "/#{self.flat}" if self.flat?
      s = "#{number}#{entrance}#{flat}"

      Building.new( s, street: @street )
    end
    
    def buildings
      return [ building ] if building?
      
      ar = *low..high
      ar.select!{ |n| n.send "#{even_odd}?" } if even_odd?
      
      ar.map{|num| Building.new( num.to_s, street: @street )}
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


class Buildings
  class Building
    attr_reader :number, :entrance, :street
    attr_writer :all_marked
    
    def initialize address, street: street, all_marked: nil
      @street = street
      @all_marked = all_marked
      @marked_flats = SortedSet.new
      initialize_from_string address
    end
    
    def initialize_from_string address
      sec = Section.new( address )
      raise "Cannot initialize building from #{address}" unless sec.building?
      
      @number = sec.number
      @entrance = sec.entrance
      @marked_flats << sec.flat if sec.flat?
    end
    private :initialize_from_string
    
    def entrance?
      not entrance.blank?
    end
    
    # Returns number of flats, or nil.
    def highest_flat check_street: true
      if @street and check_street
        from_street = @street.buildings[ self ].try( :highest_flat )
      end

      [from_street, @highest_flat, @marked_flats.max].compact.max
    end
    alias :flats? :highest_flat
    
    def highest_flat=( num )
      @highest_flat = [@highest_flat, num].compact.max
    end
    
    def marked_flats
      all_marked ? @marked_flats = SortedSet.new( all_flats ) : @marked_flats
    end
    
    def unmarked_flats
      all_flats - marked_flats.to_a
    end
    
    def all_flats
      [*1..highest_flat.to_i]
    end
    
    def all_marked
      # Think thrice before changing the next line:
      return @all_marked unless @all_marked.nil?
      
      # If ever a building is reported without flats, that is an
      # Explicit way of saying it's entirely marked. Therefore you
      # actually Shouldn't check street information to find out whether
      # it's got flats or not.
      return true if not flats?( check_street: false )
      
      return true if ( @street and ( @marked_flats.size == highest_flat ) )
    end
    alias :all_marked? :all_marked
    
    
    def address
      "#{number}#{entrance}"
    end
    
    def to_s
      return "#{address}/#{marked_flats.first}" if marked_flats.one?
      
      flats = " (#{ConciseString.new(marked_flats).str})" if marked_flats.any?
      flats = "" if all_marked?
      
      "#{address}#{flats}"
    end
    
    def ==( other )
      address == other.address
    end
    
    def <=>( other )
      a, b = [self, other].map do |bld|
        [ bld.number, bld.entrance.to_s ] + [ bld.marked_flats.first.to_i ]
      end

      a <=> b 
    end
    
    def merge buildings
      @all_marked = ( all_marked? or buildings.any?(&:all_marked?) )
      other_flats = buildings.flat_map{ |bld| bld.marked_flats.to_a }
      marked_flats.merge other_flats
      
      self
    end
    
    def splat
      marked_flats.map do |flat|
        Building.new( "#{address}/#{flat}", street: @street )
      end
    end
    
    def switch_markings
      # The next line seems unnecessary, but if highest_flat is taken from
      # highest marked flat, switching its status could result in a lower
      # highest_flat. This ensures it remains.
      self.highest_flat = highest_flat
      
      marked_flats.replace unmarked_flats
    end
    
    # Determines whether this building is known to be last on the street
    # or whether this is unknown yet.
    def unconfirmed_last?
      return true if @street.nil?
      
      not @street.high_building? and ( self == street.buildings.last )
    end
    
    def last_on_street?
      self == @street.buildings.last
    end
    
    def partially_marked?
      marked_flats.any? and not all_marked?
    end
  end
  # end of class Building
end


class Buildings
  # Service class for filling gaps in building ranges.
  class BuildingsFiller
    
    def initialize buildings, street
      @street = street
      @buildings = buildings
      fill_building_gaps
    end
    
    def fill_building_gaps
      fill_from_street if @street
      fill_entrances
      fill_numbers
    end
    
    def fill_from_street
      street_blds = @street.buildings.to_a.map(&:address)
      my_blds = @buildings.map(&:address)
      diff_blds = street_blds - my_blds
      
      diff_blds.map!{ |bld| empty_building_for( bld ) }
      @buildings.concat diff_blds
    end
    
    def fill_entrances
      by_number = buildings_with_entrances.group_by(&:number)
      by_number.each do |number, buildings|
        entrances = buildings.map(&:entrance)
        highest_entrance = entrances.max
        missing_entrances = [*"a"..highest_entrance] - entrances
        missing_entrances.each do |entrance|
          @buildings << empty_building_for( "#{number}#{entrance}" )
        end
      end
    end
  
    def fill_numbers
      missing_numbers = all_possible_building_numbers - building_numbers
      missing_blds = missing_numbers.map do |number|
        empty_building_for( number.to_s )
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
    
    def empty_building_for address
      Building.new( address, street: @street, all_marked: false )
    end
  end
end


class Buildings
  class ConciseString
    def initialize buildings, even_odd: false, show_flats: false
      @buildings = buildings
      @bld_arrays = []
      @even_odd = even_odd
      @show_flats = show_flats
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
      @bld_arrays.sort_by{ |ar| ar.first.number }.map do |ar|
        
        if ar.first.partially_marked? and not @show_flats
          s = "#{ar.first.address}(½)"
        else
          s = "#{ar.first}"
        end
        
        if ar.many?
          s += "-#{ ar.last.number }"
          s += (ar.first.number.even? ? ' even' : ' odd') if @even_odd
        end
        s
      end
    end
  end
  # end of class ConciseString
end
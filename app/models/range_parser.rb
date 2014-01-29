class RangeParser
  attr_reader :range_str, :last_error
  attr_accessor :sort, :splat_flats, :switch_markings
  
  def initialize range_str, sort: true, splat_flats: false
    self.range_str = range_str
    @sort = sort
    @splat_flats = splat_flats
    @switch_markings = switch_markings
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
    buildings()
    
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
    
    switch_markings_for( buildings ) if switch_markings
    
    splat_flats_for( buildings ) if splat_flats

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
  
  def splat_flats_for buildings
    buildings.map!(&:splat).flatten!
  end
  private :splat_flats_for
  
  def switch_markings_for buildings
    buildings.each &:switch_markings
  end
  private :switch_markings_for
  
  # Sorts buildings without regard to whether 'sort' is set to true or false.
  def to_str even_odd: false
    cs = ConciseString.new( buildings, even_odd: even_odd ).str
  end
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
      flat ? bld.marked_flats << flat : bld.all_marked = true
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
    attr_accessor :all_marked
    alias :all_marked? :all_marked
    
    def initialize number, entrance = nil
      @number = number
      @entrance = entrance
      @marked_flats = SortedSet.new
    end
    
    def entrance?
      not entrance.blank?
    end
    
    # Returns number of flats, or nil.
    def highest_flat
      [@highest_flat, @marked_flats.max].compact.max
    end
    
    def flats?
      highest_flat.present?
    end
    
    def highest_flat=( num )
      @highest_flat = [@highest_flat, num].compact.max
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
        b = RangeParser::Building.new( number, entrance )
        ( b.marked_flats << flat ) and b
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

class RangeParser
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
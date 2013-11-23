class RangeParser
  attr_reader :range_str
  
  def initialize range_str, sort: true
    self.range_str = range_str
    @sort = sort
  end
  
  def range_str=( str )
    @range_str = str
    @parses = nil
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
  rescue
    # Possibly add the error to an errors collection
    @parses = false
  end
  
  def buildings
    return @buildings if @buildings
    
    all_buildings = sections.flat_map(&:buildings)
    
    grouped = all_buildings.group_by(&:building)
    
    @buildings = grouped.map do |building, buildings|
      other_covered_flats = buildings.drop( 1 ).map(&:flats)
      buildings.first.covered_flats.concat( other_covered_flats ).sort!
      buildings.first
    end
    
    if @sort
      @buildings.sort! do |bld1, bld2|
        [ bld1.number, bld1.entrance ] <=> [ bld2.number, bld2.entrance ]
      end
    end
    
    @buildings 
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
      Building.new( number, entrance, flat )
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
      raise if range? and
        ( flat? or entrance? )

      raise if even_odd? and
        ( flat? or entrance? )
        
      raise if str.blank?
      raise if range? and low >= high
      raise if number.nil? and not range?
      raise if range? and low <= 0
      raise if building? and number <= 0
    end
  end
  # end of class Section
end


class RangeParser
  class Building
    attr_reader :number, :entrance
    
    def initialize number, entrance = nil, flat = nil
      @number = number.to_i
      @entrance = entrance
      covered_flats << flat if flat
    end
    
    # Returns number of flats, or nil.
    def flats
      covered_flats.max if covered_flats.any?
    end
    
    def covered_flats
      @covered_flats ||= []
    end
    
    def uncovered_flats
      [*1..flats] - covered_flats if flats
    end
    
    def building
      "#{number}#{entrance}"
    end
  end
  # end of class Building
end
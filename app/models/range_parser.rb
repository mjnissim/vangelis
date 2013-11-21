class RangeParser
  attr_reader :range_str
  
  def initialize range_str, uniq: true, sort: true
    self.range_str = range_str
    @uniq = uniq
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
  
  def parses?
    return @parses unless @parses.nil?
    
    # One of the sections will throw an exception if unparsable:
    section_strings.each{ | section_str | Section.new( section_str ) }
    
    @parses = true
  rescue
    # Possibly add to an errors collection
    @parses = false
  end
  
  def to_a
    ar = section_strings.flat_map do | section_str |
      Section.new( section_str ).to_a
    end
    
    ar.uniq! if @uniq
    ar.sort!{ |e1, e2| [ e1.to_i, e1 ] <=> [ e2.to_i, e2 ] } if @sort
    ar
  end
end


class RangeParser
  class Section
    attr_reader :str
    
    def initialize str
      @str = str.dup
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
      if single_block?
        n = str.match( /(\d+)/ ).try( :[], 1 )
        n.to_i if n
      end
    end
    
    def number_entrance_flat
      "#{number}#{entrance}/#{flat}" if single_block?
    end
    
    def single_block?
      not range?
    end
    
    def to_a
      return [ number_entrance_flat ] if single_block?
      
      ar = *low..high
      even_odd ? ar.select{ |n| n.send "#{even_odd}?" } : ar
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
      raise if to_a.first.to_i <= 0
    end
  end
  # end of class Section
end
class RangeParser
  attr_reader :range_str
  
  def initialize range_str, uniq: true, sort: true
    self.range_str = range_str
    @uniq = uniq
    @sort = sort
  end
  
  def range_str= range_str
    @range_str = range_str
    parse
  end
  
  def parses?
    @parses
  end
  
  def to_a
    # Important to implement this method.
  end
  
  
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
    
    def validate!
      raise if range? and
        ( flat? or entrance? )

      raise if even_odd? and
        ( flat? or entrance? )
    end

    def range?
      str.include?( "-" )
    end
  end
  # end of class Section
  
  
private
  def parse
    # Clean it up and get it ready for parsing
    section_strings = @range_str.to_s.delete( " " ).split( "," ).reject(&:blank?)

    section_strings.each do |section_str|
      section = Section.new( section_str )
      
      section.check_conditions!
            
      if section.flat?
        block, flat = e.split( "/" )
        block
        # other operations
      elsif section.entrance?
      elsif section.range?
        low, high = e.split( "-" ).map(&:to_i)
        ar = *low..high
        even_odd ? ar.select{ |n| n.send "#{even_odd}?" } : ar
      end
    end
    
    raise if @ar.none? or @ar.include?(0)
    
    @ar.uniq! if @uniq
    @ar.sort!{ |e1, e2| [ e1.to_i, e1 ] <=> [ e2.to_i, e2 ] } if @sort
    
    @parses = true
  rescue
    # Possibly add to an errors collection
    @ar = nil
    @parses = false
  end
end
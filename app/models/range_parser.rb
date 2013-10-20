class RangeParser
  attr_reader :range_str
  
  def initialize range_str, uniq: true, sort: true
    self.range_str = range_str
    @uniq = uniq
    @sort = sort
  end
  
  def parses?
    @parses
  end
  
  def range_str= range_str
    @range_str = range_str
    parse
  end
  
  def to_a
    @ar
  end
  
private
  def parse
    @ar = @range_str.to_s.delete( " " ).split( "," ).reject(&:blank?)

    @ar = @ar.flat_map do |e|
      even_odd = e.match( /.*(even|odd)/i ).try(:[],1).try(:downcase)
      e.sub! /(even|odd)/i, ""
      ar = eval "e=*(#{e.sub( "-", ".." )})"
      even_odd ? ar.select{ |n| n.send "#{even_odd}?" } : ar
    end
    
    @ar.uniq! if @uniq
    @ar.sort! if @sort
    
    @parses = true
  rescue Exception => exc
    # Possibly add to an errors collection
    @ar = nil
    @parses = false
  end
end
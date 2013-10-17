class RangeParser
  def self.parse range
    ranges = range.delete( " " ).split( "," ).reject(&:blank?)
    
    ranges.flat_map do |e|
      even_odd = e.match( /.*(even|odd)/i ).try(:[],1).try(:downcase)
      e.sub! /(even|odd)/i, ""
      range = eval "e=*(#{e.sub( "-", ".." )})"
      even_odd ? range.select{ |n| n.send "#{even_odd}?" } : range
    end
  end


  # def self.parse range
  #   ranges = range.delete( " " ).split( "," ).reject(&:blank?)
  # 
  #   ranges = ranges.flat_map do |e|
  #     eval "e=*(#{e.sub( "-", ".." )})"
  #   end
  # end
end
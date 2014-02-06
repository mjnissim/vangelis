module Ranges
  def to_range assignment_lines
    assignment_lines.flat_map(&:numbers).join( ", " )
  end
  
  def to_building_range assignment_lines
    Buildings.new( to_range( assignment_lines ) )
  end
end
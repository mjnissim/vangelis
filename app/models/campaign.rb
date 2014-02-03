class Campaign < ActiveRecord::Base
  validates :name, presence: true
  has_and_belongs_to_many :cities, uniq: true
  has_many :assignments, dependent: :destroy
  has_many :assignment_lines, through: :assignments, source: :lines
  
  include Ranges

  def ranges covered: true
    grouped_ranges covered: covered
  end
  
  # Returns ranges grouped by city and street
  def grouped_ranges covered: true
    grouped_lines.each do |city, streets|
      streets.each do |street, range_str|
        streets[ street ] = create_range( range_str, street, covered)
      end
    end
  end
  
  def grouped_lines
    assignment_lines.reduce( {} ) do |h, line|
      h[ line.city ] ||= Hash.new( "" )
      h[ line.city ][ line.street ] += ", #{line.numbers}"
      h
    end
  end
  
  def create_range str, street, covered
    return BuildingRange.new( str, street: street ) if covered
    
    br = BuildingRange.new( str, street: street, fill_gaps: true)
    br.switch_markings = true
    br
  end
  private :create_range
  
  def entirely_uncovered_streets
    all_streets = Street.where( city_id: city_ids ).includes( :city )
    streets_with_lines = assignment_lines.map(&:street).uniq
    entirely_uncovered_streets = all_streets - streets_with_lines
    
    entirely_uncovered_streets.group_by(&:city)
  end
end

class City < ActiveRecord::Base
  validates :name, uniqueness: true
  has_and_belongs_to_many :campaigns, uniq: true
  has_many :streets
  has_many :assignment_lines, through: :streets
  
  # include Ranges
  # 
  # # returns a hash of all the highest flat numbers in a street.
  # def highest_flat_numbers
  #   lines_by_street.reduce({}) do |h, street_lines|
  #     building_rng = to_building_range( street_lines.last )
  #     h.merge( street_lines.first => building_rng )
  #   end
  # end
  # 
  # def lines_by_street
  #   assignment_lines.group_by(&:street)
  # end
end

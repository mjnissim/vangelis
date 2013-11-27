class Campaign < ActiveRecord::Base
  validates :name, presence: true
  has_and_belongs_to_many :cities, uniq: true
  has_many :assignments, dependent: :destroy
  has_many :assignment_lines, through: :assignments, source: :lines
  
  def lines_by_city_and_street covered: true
    by_city = assignment_lines.group_by(&:city)

    by_city_and_street = by_city.each do |city, lines|
      streets = lines.group_by(&:street)
      
      streets.each do |street, lines|
        # covered_streets should probably be covered_buildings
        covered_streets = lines.flat_map(&:numbers_ar).uniq.sort
        
        if covered
          streets[ street ] = covered_streets
        else # i.e. uncovered streets
          streets[ street ] = street.numbers - covered_streets
        end
        
        by_city[ city ] = streets
      end
    end
  end
  
  def entirely_uncovered_streets_by_city
    all_streets = Street.where( city_id: city_ids ).includes( :city )
    streets_with_lines = assignment_lines.map(&:street).uniq
    entirely_uncovered_streets = all_streets - streets_with_lines
    
    entirely_uncovered_streets.group_by(&:city)
  end
end

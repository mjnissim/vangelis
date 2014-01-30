class Campaign < ActiveRecord::Base
  validates :name, presence: true
  has_and_belongs_to_many :cities, uniq: true
  has_many :assignments, dependent: :destroy
  has_many :assignment_lines, through: :assignments, source: :lines
  
  include Ranges
  
  # Returns buildings grouped by city and street
  def buildings covered: true
    by_city_and_street = by_city.each do |city, lines|
      by_street = lines.group_by(&:street)
      by_street = Hash[ by_street.sort_by{ |a| a.first.name } ]
      
      by_street.each do |street, lines|
        covered_range = to_range( lines )
        covered_blds = BuildingRange.new( covered_range ).buildings
        
        if covered
          by_street[ street ] = covered_blds
          
        else
          # Get all buildings that are partially or entirely uncovered:
          
          # 1. Get all possible buildings for that street,
          #    including unreported ones:
          all_blds = street.all_buildings
          
          # 2. Subtract all fully covered_buildings:
          uncovered_blds = all_blds.reject do |known_bld|
            # First check that it exists in the covered
            # buildings at all:
            existing = covered_blds.find do |covered_bld|
              covered_bld == known_bld
            end
            # Now check if it was specifically marked as 'all marked'
            # or that the amount of marked flats in that building
            # is equal to the amount of flats that that building is
            # known to have:
            existing and
              ( existing.all_marked? or
                existing.marked_flats.size == known_bld.highest_flat.to_i
              )
          end
          
          by_street[ street ] = uncovered_blds
        end
        
        by_city[ city ] = by_street
      end
    end
  end
  
  def entirely_uncovered_streets_by_city
    all_streets = Street.where( city_id: city_ids ).includes( :city )
    streets_with_lines = assignment_lines.map(&:street).uniq
    entirely_uncovered_streets = all_streets - streets_with_lines
    
    entirely_uncovered_streets.group_by(&:city)
  end
  
  def by_city
    assignment_lines.group_by(&:city)
  end
end

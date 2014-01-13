class Campaign < ActiveRecord::Base
  validates :name, presence: true
  has_and_belongs_to_many :cities, uniq: true
  has_many :assignments, dependent: :destroy
  has_many :assignment_lines, through: :assignments, source: :lines
  
  def buildings_by_city_and_street covered: true
    # TODO: shorten this horrendously long method!
    by_city = assignment_lines.group_by(&:city)
    
    by_city_and_street = by_city.each do |city, lines|
      by_street = lines.group_by(&:street)
      by_street = Hash[by_street.sort{ |a, b| a.first.name <=> b.first.name }]
      
      by_street.each do |street, lines|
        covered_range = lines.flat_map(&:numbers).join( "," )
        covered_blds = RangeParser.new( covered_range ).buildings
        
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
            existing = covered_blds.find do |covered_bld |
              covered_bld == known_bld
            end
            # Now check if it was specifically marked as 'all covered'
            # or that the amount of covered flats in that building
            # are equal to the amount of flats that that building is
            # known to have:
            existing and
              ( existing.all_covered? or
                existing.covered_flats.size == known_bld.highest_flat.to_i
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
  
  def generate_assignments_for street, amount, residences_each
    residences = amount * residences_each
    resid_ar = uncovered_flats_for( street, residences )
    resid_ar.shuffle!
    resid_ar = resid_ar.in_groups_of(residences_each, false)
    resid_ar.map{ |grp| grp.sort }
  end
  
  def uncovered_flats_for street, amount
    # Next line has to go by campaign, of course.
    street.reported_buildings.first amount
  end
end

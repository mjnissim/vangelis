class Campaign < ActiveRecord::Base
  validates :name, presence: true
  has_and_belongs_to_many :cities, uniq: true
  has_many :assignments, dependent: :destroy
  has_many :assignment_lines, through: :assignments, source: :lines
  
  def buildings_by_city_and_street covered: true
    by_city = assignment_lines.group_by(&:city)
    
    by_city_and_street = by_city.each do |city, lines|
      by_street = lines.group_by(&:street)
      
      by_street.each do |street, lines|
        covered_range = lines.flat_map(&:numbers).join( "," )
        covered_blds = RangeParser.new( covered_range ).buildings
        
        if covered
          by_street[ street ] = covered_blds
        else
          # Get all buildings that are partially or entirely uncovered:
          
          # 1. Get all possible buildings for that street,
          # including unreported ones:
          all_blds = street.all_buildings
          
          # 2. Subtract all fully covered_buildings:
          uncovered_blds = all_blds.reject do |bld|
            existing = covered_blds.find{ |cbld | cbld == bld }
            existing and
              ( existing.all_covered? or
                existing.covered_flats.size == bld.highest_flat
              )
          end
          
          by_street[ street ] = uncovered_blds
        end
        
        by_city[ city ] = by_street
      end
    end
  end
  
  # def lines_by_city_and_street covered: true
  #   by_city = assignment_lines.group_by(&:city)
  # 
  #   by_city_and_street = by_city.each do |city, lines|
  #     streets = lines.group_by(&:street)
  #     
  #     streets.each do |street, lines|
  #       covered_buildings = lines.flat_map(&:numbers_ar).uniq.sort
  #       
  #       if covered
  #         streets[ street ] = covered_buildings
  #       else # i.e. uncovered streets
  #         streets[ street ] = street.numbers - covered_buildings
  #       end
  #       
  #       by_city[ city ] = streets
  #     end
  #   end
  # end
  
  def entirely_uncovered_streets_by_city
    all_streets = Street.where( city_id: city_ids ).includes( :city )
    streets_with_lines = assignment_lines.map(&:street).uniq
    entirely_uncovered_streets = all_streets - streets_with_lines
    
    entirely_uncovered_streets.group_by(&:city)
  end
end

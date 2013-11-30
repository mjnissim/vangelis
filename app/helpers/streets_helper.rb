module StreetsHelper
  
  def display_buildings street, buildings, covered: true
    ar = buildings.map do |bld|
      s = "#{bld.building}"
      if covered
        s << "#{' (partial)' if bld.uncovered_flats.any?}"
      else
        if bld.uncovered_flats.any?
          s << " (fl. #{bld.uncovered_flats.join(', ')})"
        end
      end
      s
    end
    # "#{' (' + bld.highest_flat.to_s + ' flats)' if bld.highest_flat}"
    ar.join( ", ")

  end
  
  # If it needs a link to confirm the high number
  # first_buildings = buildings[0...-1]
  # 
  # concat buildings.join( ", " )
  # concat ", " if buildings.last
  # link_to( buildings.last, nil )
  
  def needs_link_to_confirm_high_number? street, buildings
    not street.high_building? and ( buildings.last == street.buildings.last )
  end
end

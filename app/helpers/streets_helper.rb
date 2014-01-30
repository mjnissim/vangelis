module StreetsHelper
  def needs_link_to_confirm_high_number? street, building
    not street.high_building? and ( building == street.all_buildings.buildings.last )
  end
end

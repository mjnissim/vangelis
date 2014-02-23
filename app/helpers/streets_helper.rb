module StreetsHelper
  def link_to_confirm_high_number building
    link_to building.address,
      set_high_building_street_path( building.street, number: building.address,
      campaign_id: @campaign.id), method: :patch,
      data: { confirm: "Are you sure you would like to change \
      #{building.street.name} high number to #{building.address}?" }
  end
  
  def all_buildings_except_last range
    cs = Buildings::ConciseString.new( range.except_last,
      even_odd: range.switch_markings?, show_flats: range.switch_markings? )
    cs.str
  end
end

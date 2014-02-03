module StreetsHelper
  def link_to_confirm_high_number building
    link_to building.building,
      { controller: :streets, action: :set_high_building,
      id: building.street.id, number: building.building, campaign_id: @campaign.id},
      method: :patch, confirm: "Are you sure you would like to change #{building.street.name} high number to #{building.building}?"
  end
  
  def all_buildings_except_last range
    cs = BuildingRange::ConciseString.new( range.except_last,
      even_odd: range.switch_markings? )
    cs.str
  end
end

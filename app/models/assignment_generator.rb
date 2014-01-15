class AssignmentGenerator
  def initialize campaign, street, amount, residences_each
    @campaign, @street, @amount, @residences_each =
      campaign, street, amount, residences_each
    @residences = uncovered_flats
  end
  
  def generate
    smart_shuffle
    limit
    set_in_groups
    internally_sort_groups
    @residences
  end
  
  def amount_of_residences
    @amount * @residences_each
  end
  
  def uncovered_flats
    uncovered_buildings.flat_map do |bld|
      new_buildings_for_flats( bld.uncovered_flats, bld )
    end
  end
  
  def uncovered_buildings
    blds = @campaign.buildings_by_city_and_street(covered: false)
    blds[@street.city][@street]
  end
  
  
  private
  
  def new_buildings_for_flats flats, bld
    return bld if flats.none?
    flats.map{ |flat| new_building_for flat, bld }
  end
  
  def new_building_for flat, bld
    b = RangeParser::Building.new( bld.number, bld.entrance )
    b.covered_flats<<flat
    b
  end
  
  # Devides all residences to two arrays, setting buildings without flats
  # at the end. Then it internally shuffles each array and joins them.
  # This produces a relatively random order while giving buildings with
  # flats the preferance
  def smart_shuffle
    @residences = @residences.partition{ |bld| bld.covered_flats.any? }
    @residences.each(&:shuffle!).flatten!
  end
  
  def limit
    @residences = @residences.first( amount_of_residences )
  end
  
  def internally_sort_groups
    @residences.each{ |grp| grp.sort! }
  end
  
  def set_in_groups
    @residences = @residences.in_groups_of( @residences_each, false )
  end
end
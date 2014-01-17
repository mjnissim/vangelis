class AssignmentGenerator
  def initialize campaign, street, amount, residences_each
    @campaign, @street, @amount, @residences_each =
      campaign, street, amount.to_i, residences_each.to_i
    @residences = uncovered_flats
  end
  
  def generate
    smart_shuffle
    set_in_groups
    internally_sort_groups
    @groups
  end
  
  def smart_shuffle
    separate_non_flats
    sort_by_largest_chunk
    transpose_by_largest_chunk
    @residences = @flats + @non_flats
  end
  
  def largest_chunk
    return @largest_chunk if @largest_chunk
    @largest_chunk = grouped_by_building.map(&:size).max
    @largest_chunk ||= 1
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
  
  def grouped_by_building
    @flats.group_by(&:building).values
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
  
    def sort_by_largest_chunk
      @flats = grouped_by_building.sort{ |a,b| b.size <=> a.size }.flatten
    end
  
    def transpose_by_largest_chunk
      @flats = @flats.in_groups_of( largest_chunk )
      @flats = @flats.transpose.flatten.compact
    end
    
    def separate_non_flats
      @flats, @non_flats = @residences.partition{ |b| b.covered_flats.any? }
    end
    
    def internally_sort_groups
      @groups.each &:sort!
    end
    
    def set_in_groups
      @groups = @residences.in_groups_of( @residences_each ).first( @amount )
    end
end
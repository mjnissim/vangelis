class AssignmentGenerator
  attr_reader :assignment_lines, :street, :campaign, :amount, :residences_each
  
  def initialize campaign, street, amount, residences_each
    @campaign, @street, @amount, @residences_each =
      campaign, street, amount.to_i, residences_each.to_i
    @residences = uncovered_flats
    generate
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
    rng = uncovered_range
    rng.splat = true
    @residences = rng.buildings
  end
  
  def uncovered_range
    ranges = @campaign.ranges( covered: false, street: @street )
    ranges[@street.city][@street]
  end
  
  
  private
  
    def generate
      smart_shuffle
      set_in_groups
      internally_sort_groups
      generate_assignment_lines_from_groups
    end
    
    def generate_assignment_lines_from_groups
      @assignment_lines = @groups.inject({}) do |h, group|
        name = NameGenerator.generate
        h.merge name => assignment_from_group( group )
      end
    end
    
    def assignment_from_group grp
      "#{ @street.name } #{ grp.join(", ") }"
    end
    
    def grouped_by_building
      @residences.group_by(&:address).values
    end
  
    def smart_shuffle
      sort_by_largest_chunk
      transpose_by_largest_chunk
    end
    
    def sort_by_largest_chunk
      @residences = grouped_by_building.sort{ |a,b| b.size <=> a.size }.flatten
    end
  
    def transpose_by_largest_chunk
      @residences = @residences.in_groups_of( largest_chunk )
      @residences = @residences.transpose.flatten.compact
    end
    
    def internally_sort_groups
      @groups.each &:sort!
    end
    
    def set_in_groups
      @groups = @residences.in_groups_of( @residences_each, false ).first( @amount )
    end
end
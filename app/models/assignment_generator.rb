class AssignmentGenerator
  attr_reader :assignment_lines, :street, :campaign, :amount, :residences_each
  
  def initialize campaign, street, amount, residences_each
    @campaign, @street, @amount, @residences_each =
      campaign, street, amount.to_i, residences_each.to_i
    @residences = uncovered_flats
    # generate
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
    rng.buildings.select!(&:flats?)
    rng
  end
  
  def uncovered_range
    ranges = @campaign.ranges(covered: false)
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
        name = NameGenerator.new.generate
        h.merge name => assignment_from_group( group )
      end
    end
    
    def assignment_from_group grp
      buildings = grp.map do |bld| 
        s = bld.address 
        s << ( bld.marked_flats.any? ? "/#{bld.marked_flats.first}" : "" )
      end
      "#{ @street.name } #{ buildings.join(", ") }"
    end
    
    def grouped_by_building
      @flats.group_by(&:address).values
    end
  
    def smart_shuffle
      separate_non_flats
      sort_by_largest_chunk
      transpose_by_largest_chunk
      recombine_non_flats
    end
    
    def sort_by_largest_chunk
      @flats = grouped_by_building.sort{ |a,b| b.size <=> a.size }.flatten
    end
  
    def transpose_by_largest_chunk
      @flats = @flats.in_groups_of( largest_chunk )
      @flats = @flats.transpose.flatten.compact
    end
    
    def separate_non_flats
      @flats, @non_flats = @residences.partition{ |b| b.marked_flats.any? }
    end
    
    def internally_sort_groups
      @groups.each &:sort!
    end
    
    def set_in_groups
      @groups = @residences.in_groups_of( @residences_each, false ).first( @amount )
    end
    
    def recombine_non_flats
      @residences = @flats + @non_flats
    end
end
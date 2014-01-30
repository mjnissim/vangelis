require 'test_helper'

class BuildingRangeTest < ActiveSupport::TestCase
  test "Regular section" do
    r = BuildingRange::Section.new "1-5"
    buildings = [1,2,3,4,5].map{ |n| BuildingRange::Building.new( n ) }
    assert_equal buildings, r.buildings
  end
  
  test "Section includes zero or lower" do
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "0"
    end
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "-1"
    end
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "-3-4"
    end
  end
  
  test "Raises exception on no building number" do
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "a/7"
    end
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "/7"
    end
  end
  
  test "Raises exception on no bad section" do
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "1a/7 a/7"
    end
  end
  
  test "Raises exception if no elements" do
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "10-9"
    end
  end

  test "Raises exception for empty range" do
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "-"
    end
  end

  test "raises exception if no building number" do
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "b"
    end
  end

  test "section high lower than or equal to low" do
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "10-10"
    end
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "11-10"
    end
  end

  test "section low" do
    r = BuildingRange::Section.new "1-5"
    assert_equal 1, r.low
  end

  test "section high" do
    r = BuildingRange::Section.new "1-5"
    assert_equal 5, r.high
  end
  
  test "even/odd section range" do
    r = BuildingRange::Section.new "1-5 odd"
    buildings = [1,3,5].map{ |e| BuildingRange::Building.new( e ) }
    assert_equal buildings, r.buildings
    r = BuildingRange::Section.new "1-5 even"
    buildings = [2,4].map{ |e| BuildingRange::Building.new( e ) }
    assert_equal buildings, r.buildings
  end

  test "section flat number" do
    r = BuildingRange::Section.new "10/3"
    assert_equal 3, r.flat
    r = BuildingRange::Section.new "10a/3"
    assert_equal 3, r.flat
  end

  test "section has flat" do
    r = BuildingRange::Section.new "10/3"
    assert r.flat?
    r = BuildingRange::Section.new "10a/3"
    assert r.flat?
  end

  test "section doesn't have flat" do
    r = BuildingRange::Section.new "10"
    assert !r.flat?
    r = BuildingRange::Section.new "10-15"
    assert !r.flat?
    r = BuildingRange::Section.new "10b"
    assert !r.flat?
  end

  test "section entrance" do
    r = BuildingRange::Section.new "10b"
    assert_equal "b", r.entrance
    r = BuildingRange::Section.new "10B"
    assert_equal "b", r.entrance
    r = BuildingRange::Section.new "10g"
    assert_equal "g", r.entrance
    r = BuildingRange::Section.new "10b/5"
    assert_equal "b", r.entrance
  end

  test "section has entrance?" do
    r = BuildingRange::Section.new "10b"
    assert r.entrance?
    r = BuildingRange::Section.new "10B"
    assert r.entrance?
    r = BuildingRange::Section.new "10g"
    assert r.entrance?
    r = BuildingRange::Section.new "10b/5"
    assert r.entrance?
  end

  test "section building number" do
    r = BuildingRange::Section.new "10-15"
    assert_nil r.number
    r = BuildingRange::Section.new "10b"
    assert_equal 10, r.number
    r = BuildingRange::Section.new "10b/3"
    assert_equal 10, r.number
  end

  test "get number, entrance and flat" do
    r = BuildingRange::Section.new "10b/6"
    assert_equal "10b", r.building.building
    assert_equal 6, r.building.highest_flat
  end

  test "section single building?" do
    r = BuildingRange::Section.new "10b/6"
    assert r.building?
  end

  test "array of section single building" do
    r = BuildingRange::Section.new "10-12"
    assert !r.building?
  end

  test "section even/odd" do
    r = BuildingRange::Section.new "10-20 even"
    assert_equal "even", r.even_odd
    r = BuildingRange::Section.new "10-20 odd"
    assert_equal "odd", r.even_odd
  end

  test "section has even/odd" do
    r = BuildingRange::Section.new "10-20 even"
    assert r.even_odd?
    r = BuildingRange::Section.new "10-20 odd"
    assert r.even_odd?
  end

  test "section is a range?" do
    r = BuildingRange::Section.new "10-12"
    assert r.range?
    r = BuildingRange::Section.new "10b/6"
    assert !r.range?
  end

  test "combined range and flat" do
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "10/6-12"
    end
  end
  
  test "combined range and entrance" do
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "10b-12"
    end
  end
  
  test "combined even/odd and flat" do
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "10/6-12 even"
    end
  end

  test "combined even/odd and entrance" do
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "10b-12 odd"
    end
  end
  
  test "Empty section" do
    assert_raise(RuntimeError) do
      BuildingRange::Section.new ""
    end
  end

  test "Raises on malformed sections" do
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "1a/7a/7"
    end
    assert_raise(RuntimeError) do
      BuildingRange::Section.new "10/3a"
    end
  end

  test "BuildingRange sort" do
    r = BuildingRange.new "2, 10b/6, 10b/20"
    assert_equal ["2", "10b"] , r.buildings.map(&:building)
    assert_equal [6, 20], r.buildings.second.marked_flats.to_a
  end
  
  test "Consider all flats marked if block without flats" do
    rp = BuildingRange.new "9-10, 10/6, 10/8"
    bld = rp.buildings.second
    bld.all_marked = true
    assert_equal 8, bld.highest_flat
    assert_equal [1,2,3,4,5,6,7,8], bld.marked_flats.to_a
  end
  
  test "even after adding changing to 'all_marked' it records higher numbers" do
    rp = BuildingRange.new "9-10, 10/6"
    bld = rp.buildings.second
    bld.all_marked = true
    bld.marked_flats << 8
    assert_equal 8, bld.highest_flat
    assert_equal [1,2,3,4,5,6,7,8], bld.marked_flats.to_a
  end
  
  test "Properly merges 'all_marked'" do
    rp = BuildingRange.new "10/6, 10, 10/3"
    bld = rp.buildings.first
    assert true, bld.all_marked?
    assert_equal SortedSet.new([*1..6]), bld.marked_flats
  end
  
  test "Fills gaps in building ranges" do
    rp = BuildingRange.new( "5-7, 1d, 1b", fill_gaps: true )
    blds  = rp.buildings
    nums = ["1a", "1b", "1c", "1d", "2", "3", "4", "5", "6", "7"]
    assert_equal nums, blds.map(&:building)
  end
  
  test "Accepts entrance and non-entrance together" do
    rp = BuildingRange.new "87/9, 87a/6"
    blds  = rp.buildings
    nums = ["87", "87a"]
    assert_equal nums, blds.map(&:building)
  end
  
  test "No comma between buildings is also parsable" do
    rp = BuildingRange.new "101, 111b/9 111a/6 1-5 even 10-15 odd"
    ar = ["2", "4", "11", "13", "15", "101", "111a", "111b"]
    assert_equal ar, rp.buildings.map(&:building)
  end
  
  test "Concise String works" do
    rp = BuildingRange.new('1a 2 3 4 5 6 7 8 8a 9/12 10 11 12 13 14 15 16 18-20')
    str = "1a, 2-8, 8a, 9/12, 10-16, 18-20"
    assert_equal str, rp.to_str
  end
  
  test "Concise String works with even odd" do
    rp = BuildingRange.new('1a 2 3 4 5 6 7 8 8a 9/12 10 11 12 13 14 15 16 18-20')
    str = "1a, 3-7, 9/12, 11-15, 19, 2-8, 8a, 10-20"
    assert_equal str, rp.to_str( even_odd: true )
  end
  
  test "splat flats" do
    rp = BuildingRange.new('3b/6, 3b/4, 3a')
    rp.splat = true
    str = "3a, 3b/4, 3b/6"
    assert_equal str, rp.buildings.map(&:to_s).join(", ")
  end
  
  test "splat flats without sort (but sort flats internally)" do
    rp = BuildingRange.new('3b/6 3b/4 3a')
    rp.sort = false
    rp.splat = true
    str = "3b/4, 3b/6, 3a"
    assert_equal str, rp.buildings.map(&:to_s).join(", ")
  end
  
  test "Switch flat's markings" do
    rp = BuildingRange.new('3b/6 3b/4 3a')
    rp.switch_markings = true
    str = "3a, 3b (1, 2, 3, 5)"
    assert_equal str, rp.buildings.map(&:to_s).join(", ")
  end
  
  test "Switch flat's markings and splat flats" do
    rp = BuildingRange.new('3b/6 3b/4 3a')
    rp.splat = true
    rp.switch_markings = true
    str = "3a, 3b/1, 3b/2, 3b/3, 3b/5"
    assert_equal str, rp.buildings.map(&:to_s).join(", ")
  end
end

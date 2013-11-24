require 'test_helper'

class RangeParserTest < ActiveSupport::TestCase
  test "Regular section" do
    r = RangeParser::Section.new "1-5"
    buildings = [1,2,3,4,5].map{ |n| RangeParser::Building.new( n ) }
    assert_equal buildings, r.buildings
  end
  
  test "Section includes zero or lower" do
    assert_raise(RuntimeError) do
      RangeParser::Section.new "0"
    end
    assert_raise(RuntimeError) do
      RangeParser::Section.new "-1"
    end
    assert_raise(RuntimeError) do
      RangeParser::Section.new "-3-4"
    end
  end
  
  test "Raises exception if no elements" do
    assert_raise(RuntimeError) do
      RangeParser::Section.new "10-9"
    end
  end

  test "Raises exception for empty range" do
    assert_raise(RuntimeError) do
      RangeParser::Section.new "-"
    end
  end

  test "raises exception if no building number" do
    assert_raise(RuntimeError) do
      RangeParser::Section.new "b"
    end
  end

  test "section high lower than or equal to low" do
    assert_raise(RuntimeError) do
      RangeParser::Section.new "10-10"
    end
    assert_raise(RuntimeError) do
      RangeParser::Section.new "11-10"
    end
  end

  test "section low" do
    r = RangeParser::Section.new "1-5"
    assert_equal 1, r.low
  end

  test "section high" do
    r = RangeParser::Section.new "1-5"
    assert_equal 5, r.high
  end
  
  test "even/odd section range" do
    r = RangeParser::Section.new "1-5 odd"
    assert_equal r.to_a, [1,3,5]
    r = RangeParser::Section.new "1-5 even"
    assert_equal r.to_a, [2,4]
  end

  test "section flat number" do
    r = RangeParser::Section.new "10/3"
    assert_equal 3, r.flat
    r = RangeParser::Section.new "10/3a"
    assert_equal 3, r.flat
  end

  test "section has flat" do
    r = RangeParser::Section.new "10/3"
    assert r.flat?
    r = RangeParser::Section.new "10/3a"
    assert r.flat?
  end

  test "section doesn't have flat" do
    r = RangeParser::Section.new "10"
    assert !r.flat?
    r = RangeParser::Section.new "10-15"
    assert !r.flat?
    r = RangeParser::Section.new "10b"
    assert !r.flat?
  end

  test "section entrance" do
    r = RangeParser::Section.new "10b"
    assert_equal "b", r.entrance
    r = RangeParser::Section.new "10B"
    assert_equal "b", r.entrance
    r = RangeParser::Section.new "10g"
    assert_equal "g", r.entrance
    r = RangeParser::Section.new "10b/5"
    assert_equal "b", r.entrance
  end

  test "section has entrance?" do
    r = RangeParser::Section.new "10b"
    assert r.entrance?
    r = RangeParser::Section.new "10B"
    assert r.entrance?
    r = RangeParser::Section.new "10g"
    assert r.entrance?
    r = RangeParser::Section.new "10b/5"
    assert r.entrance?
  end

  test "section building number" do
    r = RangeParser::Section.new "10-15"
    assert_nil r.number
    r = RangeParser::Section.new "10b"
    assert_equal 10, r.number
    r = RangeParser::Section.new "10b/3"
    assert_equal 10, r.number
  end

  test "get number, entrance and flat" do
    r = RangeParser::Section.new "10b/6"
    assert_equal "10b/6", r.number_entrance_flat
  end

  test "section single building?" do
    r = RangeParser::Section.new "10b/6"
    assert r.building?
  end

  test "array of section single building" do
    r = RangeParser::Section.new "10-12"
    assert !r.building?
  end

  test "section even/odd" do
    r = RangeParser::Section.new "10-20 even"
    assert_equal "even", r.even_odd
    r = RangeParser::Section.new "10-20 odd"
    assert_equal "odd", r.even_odd
  end

  test "section has even/odd" do
    r = RangeParser::Section.new "10-20 even"
    assert r.even_odd?
    r = RangeParser::Section.new "10-20 odd"
    assert r.even_odd?
  end

  test "section is a range?" do
    r = RangeParser::Section.new "10-12"
    assert r.range?
    r = RangeParser::Section.new "10b/6"
    assert !r.range?
  end

  test "combined range and flat" do
    assert_raise(RuntimeError) do
      RangeParser::Section.new "10/6-12"
    end
  end
  
  test "combined range and entrance" do
    assert_raise(RuntimeError) do
      RangeParser::Section.new "10b-12"
    end
  end
  
  test "combined even/odd and flat" do
    assert_raise(RuntimeError) do
      RangeParser::Section.new "10/6-12 even"
    end
  end

  test "combined even/odd and entrance" do
    assert_raise(RuntimeError) do
      RangeParser::Section.new "10b-12 odd"
    end
  end
  
  test "even odd section range array" do
    r = RangeParser::Section.new "1-7 odd"
    assert_equal [1,3,5,7], r.to_a
    r = RangeParser::Section.new "1-7 even"
    assert_equal [2,4,6], r.to_a
  end
  
  test "Empty section" do
    assert_raise(RuntimeError) do
      RangeParser::Section.new ""
    end
  end

  test "RangeParser sort" do
    r = RangeParser.new "1b/6, 1b/20"
    assert_equal ["1b/6", "1b/20"], r.to_a
  end
end

module StreetsHelper
  
  def display_numbers street, numbers_ar
    unless needs_link_to_confirm_high_number?( street, numbers_ar )
      return numbers_ar.join( ", " ) 
    end
    
    nums = numbers_ar.dup
    last = nums.pop
    
    concat nums.join( ", " )
    concat ", " if nums.any?
    link_to( last, nil )
  end
  
  def needs_link_to_confirm_high_number? street, nums
    not street.high_number? and
      ( nums.last == street.highest_reported_number )
  end
end

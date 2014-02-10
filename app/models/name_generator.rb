class NameGenerator
  def self.generate
    new.generate
  end
  
  def generate
    rand_string( length: 2 ) + rand_number( digits: 2 ).to_s
  end
  
  def rand_string length: 1
    (1..length).map{(65 + rand(26)).chr}.join
  end
  
  def rand_number digits: 2
    min = ( 1.to_s + "0" * (digits - 1) ).to_i
    max = ( 1.to_s + "0" * digits ).to_i - 1
    rand(min..max)
  end
end

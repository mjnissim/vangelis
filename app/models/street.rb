class Street < ActiveRecord::Base
  belongs_to :city
  
  serialize :other_spellings, Array
  serialize :metaphone, Array
  
  def self.find_by_name name, city
    street = where( 'lower(name) = ? and city_id = ?',
      name.downcase, city ).first
    return street if street.present?

    street = where( city: city ).find do |street|
      street.other_spellings.map(&:downcase).include?( name.downcase )
    end
  end
  
  def self.search_by_sound name, city
    mp = Text::Metaphone.double_metaphone( name )
    mp.compact!
    where( city: city ).select{ |s| ( s.metaphone - mp ).size < s.metaphone.size }
  end
  
  before_save do
    if self.name_changed?
      mp = Text::Metaphone.double_metaphone( self.name )
      self.metaphone = mp.compact
    end
    true
  end
end

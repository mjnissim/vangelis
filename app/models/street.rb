class Street < ActiveRecord::Base
  belongs_to :city
  
  serialize :other_spellings, Set
  serialize :metaphone, Array
  
  def self.find_by_name name, city
    street = city.streets.where( 'lower(name) = ?', name.downcase ).first
    return street if street.present?

    street = city.streets.find do |street|
      street.other_spellings.map(&:downcase).include?( name.downcase )
    end
  end
  
  def self.search_similar name, city
    ( search_by_sound( name, city ) +
      drop_or_add_the( name, city )  ).uniq
  end
  
  def self.search_by_sound name, city
    mp = Text::Metaphone.double_metaphone( name )
    mp.compact!
    
    city.streets.select{ |s| ( s.metaphone & mp ).any? }
  end
  
  # "Ha" is the Hebrew equivalent to "The". Dropping "Ha"
  # from names, or adding it, can help with finding streets.
  def self.drop_or_add_the name, city
    # also treats "he" for names like "HeCharuv"
    name = name.downcase
    drop_the = name.sub( /(ha|he)\'?/, "" )
    add_the = ["ha", "he", "ha'", "he'"].map{ |h| h + name }
    variations = add_the + [drop_the]
    
    streets = variations.flat_map do |variation|
      search_by_sound variation, city
    end
    streets.uniq
  end
  
  before_save do
    if self.name_changed?
      mp = Text::Metaphone.double_metaphone( self.name )
      self.metaphone = mp.compact
    end
    true
  end
end

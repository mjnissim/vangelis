class AssignmentLine < ActiveRecord::Base
  belongs_to :assignment, inverse_of: :lines
  has_one :city, through: :assignment
  belongs_to :street
  
  attr_writer :confirmed_street_name
  
  validate :process_line
  
  STREET_AND_NUMBERS = /\A(\D*)\s+(\d.*)/
  
  def name
    confirmed_street_name || name_from_line
  end
  
  def confirmed_street_name
    @confirmed_street_name if @confirmed_street_name.present?
  end
  
  def name_from_line
    match.try( :[], 1 )
  end
  
  def parses?
    match.present?
  end
  
  def match
    line.match( STREET_AND_NUMBERS )
  end
  
  def process_line
    if not parses?
      msg = "Be a mensch and provide street name and block numbers."
      errors.add(:base, msg) and return
    end
    
    process_numbers and process_street
  end
  
  def process_street
    street = Street.find_by_name( name, assignment.city )

    case
    when street
      self.street = street
      update_other_spellings_for( street ) if other_spelling?
    when confirmed_street_name
      self.build_street name: name, city: assignment.city
    when similar_streets.any?
      msg = "Found similar street names. Please choose action."
      errors.add(:base, msg)
    when similar_streets.none?
      msg = "'#{name}' will be created. Please confirm."
      errors.add(:base, msg)
      self.build_street name: name, city: assignment.city
    end
  end
  
  def other_spelling?
    name != name_from_line
  end
  
  def new_street?
    self.street.try( :new_record? )
  end
  
  def update_other_spellings_for street
    other_spellings = (street.other_spellings << name_from_line)
    street.update_attributes other_spellings: other_spellings
  end
  
  def similar_streets
    return [] unless name
    
    @similar_streets ||= Street.search_similar( name, assignment.city )
    @similar_streets.reject!{ |street| street.name == name }
    @similar_streets
  end
  
  # Attempts to process block numbers and returns true or false accordingly.
  def process_numbers
    rp = BuildingRange.new( numbers )
    return true if rp.parses?
    
    errors.add( :base, rp.last_error )
    false
  end
  
  def numbers
    match.try( :[], 2 )
  end
end

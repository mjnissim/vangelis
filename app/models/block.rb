class Block < ActiveRecord::Base
  validates :number, uniqueness: { scope: :street_id }
end

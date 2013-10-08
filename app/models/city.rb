class City < ActiveRecord::Base
  validates :name, uniqueness: true
  has_and_belongs_to_many :campaigns, uniq: true
  has_many :streets
end

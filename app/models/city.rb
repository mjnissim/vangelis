class City < ActiveRecord::Base
  validates :name, uniqueness: true
  has_and_belongs_to_many :campaigns, -> { uniq }
  has_many :streets
  has_many :assignment_lines, through: :streets
end

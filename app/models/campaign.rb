class Campaign < ActiveRecord::Base
  validates :name, presence: true
  has_and_belongs_to_many :cities, uniq: true
  has_many :assignments, dependent: :destroy
end

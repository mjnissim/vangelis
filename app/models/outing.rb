class Outing < ActiveRecord::Base
  has_many :lines, :class_name => 'OutingLine',
    dependent: :destroy, inverse_of: :outing
  belongs_to :city
  
  accepts_nested_attributes_for :lines, allow_destroy: true, 
    reject_if: proc { |attributes|
      attributes['line'].blank? and
      attributes['confirmed_street_name'].blank? }
  
  validates_associated :lines
  validates :report, presence: true, :unless => "lines.any?"
  
  attr_accessor :report
  
  before_validation do |outing|
    build_lines_from_report if self.lines.none?
  end
  
  def build_lines_from_report
    lines = report.split("\n").reject(&:blank?)
    lines.each{ |line| self.lines.build line: line }
  end
  
  before_save do |outing|
    # Next line is until I allow the user to set the date himself.
    outing.date = outing.created_at || Time.now
  end
end

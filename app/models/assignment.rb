class Assignment < ActiveRecord::Base
  has_many :lines, :class_name => 'AssignmentLine',
    dependent: :destroy, inverse_of: :assignment
  belongs_to :city
  belongs_to :user
  belongs_to :campaign
  
  # SUGGESTION: MARK BLOCKS THAT ARE BEING BUILT, FOR A FUTURE VISIT.
  
  accepts_nested_attributes_for :lines, allow_destroy: true, 
    reject_if: proc { |attributes|
      attributes['line'].blank? and
      attributes['confirmed_street_name'].blank? }
  
  validates_associated :lines
  validates :report, presence: true, :unless => "lines.any?"
  
  attr_accessor :report
  
  before_validation do |assignment|
    build_lines_from_report if self.lines.none?
  end
  
  def build_lines_from_report
    lines = report.split("\n").reject(&:blank?)
    lines.each{ |line| self.lines.build line: line }
  end
  
  before_save do |assignment|
    # Next line is until I allow the user to set the date himself.
    assignment.date = assignment.created_at || Time.now
  end
end

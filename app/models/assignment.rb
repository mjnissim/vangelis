class Assignment < ActiveRecord::Base
  has_many :lines, :class_name => 'AssignmentLine',
    dependent: :destroy, inverse_of: :assignment
  belongs_to :city
  belongs_to :user
  belongs_to :campaign
  
  # SUGGESTION: MARK BLOCKS THAT ARE BEING BUILT, FOR A FUTURE VISIT.
  
  STATUSES = { completed: 'COMPLETED', assigned: 'ASSIGNED' }
  
  accepts_nested_attributes_for :lines, allow_destroy: true, 
    reject_if: proc { |attributes|
      attributes['line'].blank? and
      attributes['confirmed_street_name'].blank? }
  
  validates_associated :lines
  validates :report, presence: true, :unless => "lines.any?"
  validate :no_duplicate_streets
  
  attr_accessor :report, :double_street_name_creation
  
  before_validation do |assignment|
    build_lines_from_report if self.lines.none?
  end
  
  def build_lines_from_report
    lines = report.split("\n").reject(&:blank?)
    lines.each{ |line| self.lines.build line: line }
  end
  
  def no_duplicate_streets
    lines = self.lines.map(&:confirmed_street_name).compact
    dup = lines.detect{ |e| lines.count(e) > 1 }
    
    if dup
      self.report = self.lines.map(&:line).join("\n")
      self.lines.clear
      self.double_street_name_creation = true
      msg = "You might have a new street name appearing in
            two different lines. Please combine them."
      self.errors.add(:base, msg)
    end
  end
  
  before_save do |assignment|
    # Next line is until I allow the user to set the date himself.
    assignment.date = assignment.created_at || Time.now
  end
end

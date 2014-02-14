module AssignmentsHelper
  def assignment_help_text
    s = "<b>Put each street and its block numbers on a new line:</b>
    <br /><br />
    Hertzl 45, 46, 50-58 <br />
    Sokolov 1-10, 15, 43
    <br /><br />
    <b>Can do 'odd' and 'even' numbers as well:</b>
    <br /><br />
    Weizmann 20-40 even, 40-50 odd
    <br /><br />
    <b>Accepts entrance numbers (in English) and flat numbers:</b>
    <br /><br />
    Diezengof 15a/8, 30b/4 <br />
    <br />
    Hertzl 21/8b <= not good <br />
    Hertzl 21b/8 <= good"
    
    s.html_safe
  end
  
  def link_to_assignment_campaign assignment
    link_to "#{assignment.campaign.name} (#{assignment.city.name})",
      assignment.campaign
  end
  
  def status_color assignment
    case
    when assignment.assigned?
      "text-warning"
    when assignment.completed?
      "text-success"
    when assignment.mapping?
      "text-info"
    end
  end
  
  def streets_for assignment
    street_names = assignment.streets.map(&:name)
    s = street_names.to_sentence
    s = assignment.lines.first.line if assignment.lines.one?
    link_to s.truncate(40), assignment_url( assignment )
  end
  
  def complete_assignment assignment
    link_to "#{assignment.name} ✓", assignment_url(assignment, assignment: { status: Assignment::COMPLETED}), method: :patch,
      :class => "btn btn-mini btn-success btn-block span1",
      data: { confirm: "Was #{assignment.name} completed accurately?" }
  end
  
  def operative assignment
    name = assignment.assigned_to.try(:nickname) || assignment.user.nickname
    name.truncate(15)
  end
end

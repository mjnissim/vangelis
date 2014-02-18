class UserMailer < ActionMailer::Base
  default from: User.admin.email
  
  def assignment assignment
    @assignment = assignment
    
    mail(to: assignment.assignee.email,
      subject: "Assignment #{assignment.name} (#{assignment.streets.first.name})"
    )
  end
end

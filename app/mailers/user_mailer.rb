class UserMailer < ActionMailer::Base
  default from: User.admin.email
  
  def assignment assignment
    @assignment = assignment
    subject = "Assignment #{assignment.name} \
      (#{assignment.streets.first.name})"

    mail to: assignment.assignee.email, subject: subject
  end
end

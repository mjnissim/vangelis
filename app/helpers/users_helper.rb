module UsersHelper
  def can_delete_user? user
    user.assignments.none? and not ( user == current_user )
  end
end

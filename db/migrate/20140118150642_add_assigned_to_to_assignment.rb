class AddAssignedToToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :assignee_id, :integer
  end
end

class AddReportToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :report, :text
  end
end

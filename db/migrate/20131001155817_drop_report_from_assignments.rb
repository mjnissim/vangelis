class DropReportFromAssignments < ActiveRecord::Migration
  def change
    remove_column :assignments, :report
  end
end

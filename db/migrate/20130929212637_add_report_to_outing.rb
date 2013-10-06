class AddReportToOuting < ActiveRecord::Migration
  def change
    add_column :outings, :report, :text
  end
end

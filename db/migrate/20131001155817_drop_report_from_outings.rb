class DropReportFromOutings < ActiveRecord::Migration
  def change
    remove_column :outings, :report
  end
end

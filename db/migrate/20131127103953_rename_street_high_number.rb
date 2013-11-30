class RenameStreetHighNumber < ActiveRecord::Migration
  def self.up
    rename_column :streets, :high_number, :high_building
    change_column :streets, :high_building, :string
  end

  def self.down
    change_column :streets, :high_building, :integer
    rename_column :streets, :high_building, :high_number
  end
end

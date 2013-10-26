class AddHighNumberToStreet < ActiveRecord::Migration
  def change
    add_column :streets, :high_number, :integer
  end
end

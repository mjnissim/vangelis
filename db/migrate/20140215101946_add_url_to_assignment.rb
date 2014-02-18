class AddUrlToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :url, :string
  end
end

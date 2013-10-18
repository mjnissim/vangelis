class CreateAssignmentLines < ActiveRecord::Migration
  def change
    create_table :assignment_lines do |t|
      t.integer :assignment_id, :null => false
      t.text :line
      t.integer :street_id
      t.text :numbers

      t.timestamps
    end
  end
end

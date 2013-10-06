class CreateOutingLines < ActiveRecord::Migration
  def change
    create_table :outing_lines do |t|
      t.integer :outing_id, :null => false
      t.text :line
      t.integer :street_id
      t.text :numbers

      t.timestamps
    end
  end
end

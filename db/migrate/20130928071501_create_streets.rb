class CreateStreets < ActiveRecord::Migration
  def change
    create_table :streets do |t|
      t.integer :city_id, null: false
      t.string :name
      t.string :other_spellings
      t.string :metaphone

      t.timestamps
    end
    
    add_index :streets, :name, :unique => true
  end
end

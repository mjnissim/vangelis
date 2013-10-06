class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.integer :street_id
      t.string :number

      t.timestamps
    end
  end
end

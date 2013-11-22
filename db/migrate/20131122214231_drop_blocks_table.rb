class DropBlocksTable < ActiveRecord::Migration
  def up
    drop_table :blocks
  end

  def down
    create_table :blocks do |t|
      t.integer :street_id
      t.string :number

      t.timestamps
    end
    # raise ActiveRecord::IrreversibleMigration
  end
end

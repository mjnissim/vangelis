class CreateOutings < ActiveRecord::Migration
  def change
    create_table :outings do |t|
      t.integer :user_id, null: false
      t.integer :campaign_id, null: false
      t.datetime :date
      t.string :status
      t.integer :city_id, null: false
      t.text :comments

      t.timestamps
    end
  end
end

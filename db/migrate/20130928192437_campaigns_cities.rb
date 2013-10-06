class CampaignsCities < ActiveRecord::Migration
  def change
    create_table :campaigns_cities, :id => false do |t|
      t.references :campaign, :null => false
      t.references :city, :null => false
    end

    # Adding the index can massively speed up join tables. Don't use the
    # unique if you allow duplicates.
    add_index(:campaigns_cities, [:campaign_id, :city_id], :unique => true)
  end
end

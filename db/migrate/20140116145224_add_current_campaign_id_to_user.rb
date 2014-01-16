class AddCurrentCampaignIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :current_campaign_id, :integer
  end
end

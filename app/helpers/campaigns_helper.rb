module CampaignsHelper
  def campaign_cities campaign
    campaign.cities.map(&:name).to_sentence
  end
end

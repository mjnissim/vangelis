json.array!(@campaigns) do |campaign|
  json.extract! campaign, :name, :comments
  json.url campaign_url(campaign, format: :json)
end

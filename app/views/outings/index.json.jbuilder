json.array!(@outings) do |outing|
  json.extract! outing, :user_id, :campaign_id, :date, :status, :city_id, :comments
  json.url outing_url(outing, format: :json)
end

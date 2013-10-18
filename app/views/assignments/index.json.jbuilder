json.array!(@assignments) do |assignment|
  json.extract! assignment, :user_id, :campaign_id, :date, :status, :city_id, :comments
  json.url assignment_url(assignment, format: :json)
end

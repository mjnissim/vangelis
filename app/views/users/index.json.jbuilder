json.array!(@users) do |user|
  json.extract! user, :email, :nickname
  json.url user_url(user, format: :json)
end

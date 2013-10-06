json.array!(@cities) do |city|
  json.extract! city, :name
  json.url city_url(city, format: :json)
end

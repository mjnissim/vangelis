json.array!(@streets) do |street|
  json.extract! street, :city_id, :name, :other_spellings, :metaphone
  json.url street_url(street, format: :json)
end

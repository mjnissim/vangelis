json.array!(@blocks) do |block|
  json.extract! block, :street_id, :number
  json.url block_url(block, format: :json)
end

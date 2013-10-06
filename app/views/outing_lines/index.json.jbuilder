json.array!(@outing_lines) do |outing_line|
  json.extract! outing_line, :outing_id, :line, :street_id, :numbers
  json.url outing_line_url(outing_line, format: :json)
end

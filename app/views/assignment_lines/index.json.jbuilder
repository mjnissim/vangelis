json.array!(@assignment_lines) do |assignment_line|
  json.extract! assignment_line, :assignment_id, :line, :street_id, :numbers
  json.url assignment_line_url(assignment_line, format: :json)
end

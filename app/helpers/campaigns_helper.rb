module CampaignsHelper
  def campaign_cities campaign
    campaign.cities.map(&:name).to_sentence
  end
  
  def street_select_with_uncovered_flats
    ranges = current_campaign.ranges(covered: false)
    
    hash = ranges.reduce({}) do |h, ar|
      city, street_hash = ar
      street_hash = street_hash.reject do |street, range|
        range.flat_count.zero?
      end
      
      streets = street_hash.map do |street, range|
        s = "#{street.name} (#{ pluralize( range.flat_count, 'flat' ) })"
        [s, street.id]
      end
      
      h.merge city.name => streets
    end
    
    select_tag :street_id, grouped_options_for_select( hash )
  end
end

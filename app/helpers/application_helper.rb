module ApplicationHelper
  def campaign_city_select campaign
    campaign.cities.map{ |c| [ c.name, c.id ] }
  end

  def campaign_select
    Campaign.all.map{ |c| [ c.name, c.id ] }
  end
  
  def similar_street_select line
      ar = line.similar_streets.map{ |street|
      [ "I meant '#{street.name}'",
        street.name ]
      }
      ar = ar << ["Create New Street '#{line.name}'", line.name]
      ar
  end
end

module ApplicationHelper
  def campaign_city_select campaign
    campaign.cities.map{ |c| [ c.name, c.id ] }
  end

  def campaign_select
    Campaign.all.map{ |c| [ c.name, c.id ] }
  end
  
  # def natural_lang_for date
  #   "#{ Kronic.format( date ) } #{ date.strftime( '%H:%M' ) }"
  # end
  
  def similar_street_select line
      ar = line.similar_streets.map{ |street|
      [ "I meant '#{street.name}'",
        street.name ]
      }
      ar = ar << ["Create New Street '#{line.name}'", line.name]
      ar
  end
  
  def nice_date date
    return "" if date.blank?
    d = date.strftime( "%-d %b" )
    return d if date.year == Date.today.year
    d + " #{ date.year }"
  end

  def nice_datetime date
    return "" if date.blank?
    return date.strftime( "Today %H:%M" ) if date.today?
    return date.strftime( 'Yesterday %H:%M' ) if date.to_date == 1.days.ago.to_date
    return date.strftime( "%-d %b %H:%M" ) if date.to_date >= 1.month.ago.to_date
    return date.strftime( "%-d %b" ) if date.year == Date.today.year
    date.strftime( "%-d/%m/%Y" )
  end
end

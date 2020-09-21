# Roker - Terminal meteorologist
# Writes text forecast based on current IP location
#-------------------------
require 'date'
require 'IPinfo'
require 'json'
require 'rest-client'
#-------------------------
# Requires IPInfo.io and Dark Sky API keys
# If keys stored in external file (credentials.rb), then load
if File.file?("credentials.rb")
	require_relative 'credentials'
else
	# Else add manually
	Key_ipinfo = ""
	Key_darksky = ""
end
#-------------------------
class Location
	attr_reader :city, :country, :countryISO, :latitude, :longitude
	def initialize(details)
		@city = details.city
		@country = details.country_name
		@countryISO = details.country
		@latitude = details.latitude
		@longitude = details.longitude
	end
end
#-------------------------
# Returns Location object based on current IP address
def getLocation(access_token)
	handler = IPinfo::create(access_token)
	loc = Location.new(handler.details())
	
	return loc
end

def forecast(type="now",ipinfotoken,darkskytoken)
	# Get current location
	location = getLocation(ipinfotoken)
	
	data = getForecast(location.latitude,location.longitude,darkskytoken)
	
	# Parse into variables
	time = Time.at(data["currently"]["time"]).to_datetime
	summary = data["currently"]["summary"]
	temperature = data["currently"]["apparentTemperature"]
	feelsLikeTemp = data["currently"]["apparentTemperature"]
	humidity = (data["currently"]["humidity"].to_f * 100).to_i
	
	# Strings
	stringOpener = "Forecast for #{location.city}, #{location.country} at #{time.strftime("%H:%M")}:"
	stringSummary = "#{summary}."
	stringTemp = "Temperature is #{temperature}ºC."
	if temperature != feelsLikeTemp
		stringTemp = stringTemp[0...-1] << ", but it feels like #{feelsLikeTemp}ºC."
	end
	stringHumidity = "Humidity is #{humidity}%."
	
	output = "#{stringOpener} #{stringSummary} #{stringTemp} #{stringHumidity}"
	
	# Print output
	puts output
end

# Returns forecast data from Dark Sky API
def getForecast(lat,lon,darkskyAPIKey)
	# Configure Forecast.io API
	darkskyURL = "https://api.darksky.net/forecast/#{darkskyAPIKey}/#{lat},#{lon}?exclude=hourly,daily,flags&units=si"
	
	# Make API call
	darkskyResponse = RestClient.get(darkskyURL)
	darkskyData = JSON.parse(darkskyResponse)

	# DEBUG: JSON output
	# puts JSON.pretty_generate(darkskyData)
	
	return darkskyData
end
#-------------------------
forecast("now",Key_ipinfo,Key_darksky)
# Roker - Terminal meteorologist

require 'date'
require 'IPinfo'
require 'json'
require 'rest-client'

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

def getLocation()
	access_token = ''
	handler = IPinfo::create(access_token)
	loc = Location.new(handler.details())
	
	return loc
end

def forecast(type="now")
	# Get current location
	location = getLocation()
	
	data = getForecast(location.latitude,location.longitude)
	
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

def getForecast(lat,lon)
	# Configure Forecast.io API
	forecastioAPIKey = ""
	forecastioURL = "https://api.darksky.net/forecast/#{forecastioAPIKey}/#{lat},#{lon}?exclude=hourly,daily,flags&units=si"
	
	# Make API call
	forecastioResponse = RestClient.get(forecastioURL)
	forecastioData = JSON.parse(forecastioResponse)

	# DEBUG: JSON output
	# puts JSON.pretty_generate(forecastioData)
	
	return forecastioData
end

forecast()
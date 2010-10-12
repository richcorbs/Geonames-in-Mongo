require 'httparty'

p = HTTParty.get('http://ws.geonames.org/findNearbyPostalCodes?lat=40.376628&lng=-111.79404&maxRows=1')
q = p.parsed_response["geonames"]["code"]
puts "#{q["name"]}, #{q["adminCode1"]}, #{q["postalcode"]}"

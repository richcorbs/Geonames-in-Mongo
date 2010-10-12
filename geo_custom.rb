require 'mongo'

#Make a connection to MongoDB server running on your localhost
#create a database "locations" and a collection "nyc_restaurants"
db = Mongo::Connection.new("localhost", 27017).db("geonames")
placemarkers = db.collection("placemarkers")

#build a compound index that allows us to search by the location and by the type
#this uses the default min and max values [-180,180] use for longitude and latitude. 
#check out the mongodb documentation for other examples
placemarkers.create_index([["loc", Mongo::GEO2D]])

#geoNear returns the distance for each item and other statistics
#since it's a database command, you'll build an ordered hash.
counter = 0
zc = 0
states = { "alabama" => "AL", "alaska" => "AK", "arizona" => "AZ", "arkansas" => "AR", "california" => "CA", "colorado" => "CO", "connecticut" => "CT", "delaware" => "DE", "district of columbia" => "DC", "florida" => "FL", "georgia" => "GA", "hawaii" => "HI", "idaho" => "ID", "illinois" => "IL", "indiana" => "IN", "iowa" => "IA", "kansas" => "KS", "kentucky" => "KY", "louisiana" => "LA", "maine" => "ME", "maryland" => "MD", "massachusetts" => "MA", "michigan" => "MI", "minnesota" => "MN", "mississippi" => "MS", "missouri" => "MO", "montana" => "MT", "nebraska" => "NE", "nevada" => "NV", "new hampshire" => "NH", "new jersey" => "NJ", "new mexico" => "NM", "new york" => "NY", "north carolina" => "NC", "north dakota" => "ND", "ohio" => "OH", "oklahoma" => "OK", "oregon" => "OR", "pennsylvania" => "PA", "rhode island" => "RI", "south carolina" => "SC", "south dakota" => "SD", "tennessee" => "TN", "texas" => "TX", "utah" => "UT", "vermont" => "VT", "virginia" => "VA", "washington" => "WA", "west virginia" => "WV", "wisconsin" => "WI", "wyoming" => "WY" }

start = Time.now
File.open("custom_where.csv", "r") do |infile|
  while (line = infile.gets)
    line.strip!.gsub!(/\%2C/,'+')
    fields = line.downcase.split("+").delete_if {|x| x==''}
    fields = fields.compact
    r = placemarkers.find({"keywords" => {"$all" => fields}}).count()
    counter += 1
    zc += 1 if r == 0
    #puts counter
    puts "#{counter}:#{r.inspect}:#{fields.inspect}"
  end
end
stop = Time.now
puts "#{stop-start} seconds"
puts "#{zc} of #{counter}"

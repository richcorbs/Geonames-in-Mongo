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
no_pc = 0
start = Time.now
File.open("20k_latitude_longitude.csv", "r") do |infile|
  while (line = infile.gets)
    lat, lng = line.split(",")
    geo_near_spec = Hash.new
    geo_near_spec["geoNear"] = "placemarkers"
    geo_near_spec["near"] =  [lat.to_f,lng.to_f]
    geo_near_spec["num"] = 1
    geo_near_spec["query"] = {"feature code" => "PPL"}
    r = db.command(geo_near_spec)
    name = r["results"][0]["obj"]["name"]
    state = r["results"][0]["obj"]["admin1_code"]
    postalcode = r["results"][0]["obj"]["postalcode"]
    distance = r["results"][0]["dis"].to_f * 69
    no_pc += 1 if postalcode.nil?
    counter += 1
    puts "#{counter}: #{name}, #{state}, #{postalcode}, #{distance}" if postalcode.nil?
    #puts r.inspect
    #results.each do |k,v|
      #puts "#{k.inspect}, #{v.inspect}"
    #end 
  end
end
stop = Time.now
puts "#{stop-start} seconds"
puts "no_pc = #{no_pc}"

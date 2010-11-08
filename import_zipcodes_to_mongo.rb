require 'mongo'

db = Mongo::Connection.new().db("geonames")
placemarkers = db.collection("placemarkers")
#placemarkers.remove

counter = 0
start = Time.now
File.open("zipcodes.csv", "r") do |infile|
  while (line = infile.gets)
    # split line in to usable fields
    postalcode, state, city, soundex, lat, lng, valid, searched = line.split("\t")
    city.downcase!
    # account for multi-word city names like "El Paso"
    city[0] = city[0].upcase
    city.gsub!(/ (.)/) { " #{$1.upcase}" }
    c = placemarkers.find_one({"name" => city, "admin1_code" => state})
    if c.nil?
      # city, state is not already in the database
      # create hash for inserting into MongoDB
      doc = {"name" => city, "loc" => {"lat" => lat.to_f, "lng" => lng.to_f}, "feature class" => "P", "feature code" => "PPL", "country_code" => "US", "admin1_code" => state, "postalcodes" => [postalcode], "keywords" => [city.downcase.split(" "),state.downcase,postalcode].flatten.sort}
      placemarkers.insert(doc)
    else
      # city, state is already in the database
      # add city, state, postalcode to the keywords array if not already there
      cityfields = city.downcase.split(" ")
      placemarkers.update({"name" => city, "admin1_code" => state},{"$addToSet" => { "keywords" => {"$each" => cityfields}}})
      placemarkers.update({"name" => city, "admin1_code" => state},{"$addToSet" => { "keywords" => state.downcase}})
      placemarkers.update({"name" => city, "admin1_code" => state},{"$addToSet" => { "keywords" => postalcode}})
      # add postalcode to the postalcodes array if not already there
      placemarkers.update({"name" => city, "admin1_code" => state},{"$addToSet" => { "postalcodes" => postalcode}})
    end
    counter += 1
    puts "#{counter} : #{line}" if counter % 1000 == 0
  end
end
stop = Time.now
puts "#{counter} ZIP CODES IN: #{(stop-start)/60} minutes"

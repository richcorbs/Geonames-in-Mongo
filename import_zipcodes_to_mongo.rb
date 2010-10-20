require 'mongo'

db = Mongo::Connection.new().db("geonames")
placemarkers = db.collection("placemarkers")
#placemarkers.remove

counter = 0
File.open("zipcodes.csv", "r") do |infile|
  while (line = infile.gets)
    postalcode, state, city, soundex, lat, lng, valid, searched = line.split("\t")
    city.downcase!
    city[0] = city[0].upcase
    city.gsub!(/ (.)/) { " #{$1.upcase}" }
    c = placemarkers.find_one({"name" => city, "admin1_code" => state})
    if c.nil?
      doc = {"name" => city, "loc" => {"lat" => lat.to_f, "lng" => lng.to_f}, "feature class" => "P", "feature code" => "PPL", "country_code" => "US", "admin1_code" => state, "postalcodes" => [postalcode], "keywords" => [city.downcase.split(" "),state.downcase,postalcode].flatten.sort}
      placemarkers.insert(doc)
    else
      cityfields = city.downcase.split(" ")
      placemarkers.update({"name" => city, "admin1_code" => state},{"$addToSet" => { "keywords" => {"$each" => cityfields}}})
      placemarkers.update({"name" => city, "admin1_code" => state},{"$addToSet" => { "keywords" => state.downcase}})
      placemarkers.update({"name" => city, "admin1_code" => state},{"$addToSet" => { "keywords" => postalcode}})
      placemarkers.update({"name" => city, "admin1_code" => state},{"$addToSet" => { "keywords" => postalcode}})
    end
    counter += 1
    puts "#{counter} : #{line}"
  end
end

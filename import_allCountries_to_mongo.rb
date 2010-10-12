require 'mongo'

db = Mongo::Connection.new("localhost", 27017).db("geonames")
placemarkers = db.collection("placemarkers")
placemarkers.remove

counter = 0
File.open("allCountries.txt", "r") do |infile|
  while (line = infile.gets)

    geonameid, name, asciiname, alternatenames, latitude, longitude, feature_class, feature_code, country_code, cc2, admin1_code, admin2_code, admin3_code, admin4_code, population, elevation, gtopo30, timezone, modification_date = line.split("\t")
    doc = {"geonameid" => geonameid, "name" => name, "asciiname" => asciiname, "alternatenames" => alternatenames, "loc" => {"lat" => latitude.to_f, "lng" => longitude.to_f}, "feature class" => feature_class, "feature code" => feature_code, "country_code" => country_code, "cc2" => cc2, "admin1_code" => admin1_code, "admin2_code" => admin2_code, "admin3_code" => admin3_code, "admin4_code" => admin4_code, "population" => population, "elevation" => elevation, "gtopo30" => gtopo30, "timezone" => timezone, "modification_date" => modification_date}
    placemarkers.insert(doc)
    counter = counter + 1
    puts "#{counter}" if counter % 10000 == 0
  end
end


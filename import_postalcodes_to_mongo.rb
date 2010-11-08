require 'mongo'

db = Mongo::Connection.new("localhost", 27017).db("geonames")
placemarkers = db.collection("placemarkers")

start = Time.now
counter = 0
File.open("alternateNames.txt", "r") do |infile|
  while (line = infile.gets)
    # split line into usable fields
    alternateNameId, geonameid, isolanguage, alternate_name, isPreferredName, isShortName = line.split("\t")
    # we only care about the "post" types
    if isolanguage == "post"
      # add the postalcode to the keywords and postalcodes arrays
      placemarkers.update({"geonameid" => geonameid},{"$push" => {"postalcodes" => alternate_name}})
      placemarkers.update({"geonameid" => geonameid},{"$push" => {"keywords" => alternate_name}})
      counter += 1
      puts "#{counter} : #{line}" if counter % 1000 == 0
    end
  end
end
stop = Time.now
puts "#{counter} ZIP CODES IN: #{(stop-start)/60} minutes"

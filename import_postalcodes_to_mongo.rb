require 'mongo'

db = Mongo::Connection.new("localhost", 27017).db("geonames")
placemarkers = db.collection("placemarkers")
#placemarkers.remove

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
      puts "#{counter} : #{line}"
    end
  end
end


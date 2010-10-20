require 'mongo'

db = Mongo::Connection.new("localhost", 27017).db("geonames")
placemarkers = db.collection("placemarkers")
#placemarkers.remove

counter = 0
placemarkers.find().each do |pm|
  fields = []
  fields << pm["name"].downcase.split(" ")
  fields << pm["asciiname"].downcase.split(" ") if not pm["asciiname"].nil?
  fields << pm["alternatenames"].downcase.gsub(/ /,",").split(",") if not pm["alternatenames"].nil?
  fields << pm["countrycode"].downcase.split(" ") if not pm["countrycode"].nil?
  fields << pm["admin1_code"].downcase.split(" ") if not pm["admin1_code"].nil?
  fields << pm["admin2_code"].downcase.split(" ") if not pm["admin2_code"].nil?
  fields << pm["admin3_code"].downcase.split(" ") if not pm["admin3_code"].nil?
  fields << pm["admin4_code"].downcase.split(" ") if not pm["admin4_code"].nil?
  fields << pm["postalcode"] if not pm["postalcode"].nil?
  placemarkers.update({"geonameid" => pm["geonameid"]},{"$unset" => {"keywords" => 1}})
  placemarkers.update({"geonameid" => pm["geonameid"]},{"$set" => {"keywords" => fields.delete_if{|x| x== ""}.flatten.uniq.sort}})
  counter += 1
  puts "#{counter}:#{fields.flatten.compact.sort.uniq}" if counter %1000 == 0
end


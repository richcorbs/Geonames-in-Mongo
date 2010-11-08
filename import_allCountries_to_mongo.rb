require 'mongo'

start = Time.now
db = Mongo::Connection.new("localhost", 27017).db("geonames")
db.drop_collection("placemarkers")
placemarkers = db.collection("placemarkers")
placemarkers.create_index("geonameid")
placemarkers.create_index("keywords")
placemarkers.create_index("postalcodes")
placemarkers.create_index("name")
placemarkers.create_index("admin1_code")
placemarkers.create_index([['loc', Mongo::GEO2D]])

interesting_feature_codes = %w( PPL PPLA PPLC PPLG PPLL PPLR PPLS STLMT PPLQ PPLW )

states = { 'AL' => 'Alabama', 'AK' => 'Alaska', 'AS' => 'America Samoa', 'AZ' => 'Arizona', 'AR' => 'Arkansas', 'CA' => 'California', 'CO' => 'Colorado', 'CT' => 'Connecticut', 'DE' => 'Delaware', 'DC' => 'District of Columbia', 'FM' => 'Micronesia1', 'FL' => 'Florida', 'GA' => 'Georgia', 'GU' => 'Guam', 'HI' => 'Hawaii', 'ID' => 'Idaho', 'IL' => 'Illinois', 'IN' => 'Indiana', 'IA' => 'Iowa', 'KS' => 'Kansas', 'KY' => 'Kentucky', 'LA' => 'Louisiana', 'ME' => 'Maine', 'MH' => 'Islands1', 'MD' => 'Maryland', 'MA' => 'Massachusetts', 'MI' => 'Michigan', 'MN' => 'Minnesota', 'MS' => 'Mississippi', 'MO' => 'Missouri', 'MT' => 'Montana', 'NE' => 'Nebraska', 'NV' => 'Nevada', 'NH' => 'New Hampshire', 'NJ' => 'New Jersey', 'NM' => 'New Mexico', 'NY' => 'New York', 'NC' => 'North Carolina', 'ND' => 'North Dakota', 'OH' => 'Ohio', 'OK' => 'Oklahoma', 'OR' => 'Oregon', 'PW' => 'Palau', 'PA' => 'Pennsylvania', 'PR' => 'Puerto Rico', 'RI' => 'Rhode Island', 'SC' => 'South Carolina', 'SD' => 'South Dakota', 'TN' => 'Tennessee', 'TX' => 'Texas', 'UT' => 'Utah', 'VT' => 'Vermont', 'VI' => 'Virgin Island', 'VA' => 'Virginia', 'WA' => 'Washington', 'WV' => 'West Virginia', 'WI' => 'Wisconsin', 'WY' => 'Wyoming' }

# ALLCOUNTRIES
counter = 0
File.open("allCountries.txt", "r") do |infile|
  while (line = infile.gets)
    statename = nil
    # split the line into fields we can work with
    geonameid, name, asciiname, alternatenames, latitude, longitude, feature_class, feature_code, country_code, cc2, admin1_code, admin2_code, admin3_code, admin4_code, population, elevation, gtopo30, timezone, modification_date = line.split("\t")
    # feature_classes A and P are interesting to us, the others are not
    # feature_codes in the interesting_feature_codes array cover classes A and P
    if interesting_feature_codes.include?(feature_code) and name.index("(historical)").nil?
      # add the statename to the keywords array field
      statename = (not admin1_code.nil? and not states[admin1_code].nil?) ? states[admin1_code].downcase : nil
      alternatnames.gsub!(/\./,"")
      keywords = [name.downcase.split(" "),alternatenames.downcase.split(",").split(" "),admin1_code.downcase,admin2_code.downcase,admin3_code.downcase,admin4_code.downcase,statename].flatten.compact
      keywords.delete_if {|x| x == ""}
      keywords = keywords.flatten.uniq.sort
      # set up the hash to be inserted into MongoDB
      doc = {"geonameid" => geonameid, "name" => name, "asciiname" => asciiname, "alternatenames" => alternatenames, "loc" => {"lat" => latitude.to_f, "lng" => longitude.to_f}, "feature class" => feature_class, "feature code" => feature_code, "country_code" => country_code, "cc2" => cc2, "admin1_code" => admin1_code, "admin2_code" => admin2_code, "admin3_code" => admin3_code, "admin4_code" => admin4_code, "population" => population, "elevation" => elevation, "gtopo30" => gtopo30, "timezone" => timezone, "modification_date" => modification_date, "keywords" => keywords}
      placemarkers.insert(doc)
      counter = counter + 1
      puts "#{counter}" if counter % 100000 == 0
    end
  end
end
stop = Time.now
puts "#{placemarkers.count} RECORDS IMPORTED IN: #{(stop-start)/60} minutes"

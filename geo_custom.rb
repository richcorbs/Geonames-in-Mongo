require 'mongo'

#Make a connection to MongoDB server running on your localhost
#create a database "locations" and a collection "nyc_restaurants"
db = Mongo::Connection.new("localhost", 27017).db("geonames")
placemarkers = db.collection("placemarkers")

#build a compound index that allows us to search by the location and by the type
#this uses the default min and max values [-180,180] use for longitude and latitude. 
#check out the mongodb documentation for other examples
placemarkers.create_index([["loc", Mongo::GEO2D]])

#create index on keywords array for searching
placemarkers.create_index("keywords")

#geoNear returns the distance for each item and other statistics
#since it's a database command, you'll build an ordered hash.
counter = 0
zc = 0

start = Time.now
File.open("custom_where.csv", "r") do |infile|
  while (line = infile.gets)
    r=0
    line = line.strip.gsub(/\%2C/,'+').gsub(/\./, '')
    fields = line.downcase.split("+").delete_if {|x| x==''}
    fields = fields.compact
    # search for all search terms in the keywords array
    r = placemarkers.find({"keywords" => {"$all" => fields.sort}}).count() if (fields.size > 0 and fields.size < 5)
    i=0
    # sort search terms from longest to shortest
    fields.sort! {|x,y| y.size <=> x.size} if fields.size > 0
    while (r==0 and i < fields.size)
      # if nothing is found and there is more than one search term
      # if there is a zipcode in the search terms
      if fields[i] == fields[i].to_i.to_s
        r = placemarkers.find({"keywords" => {"$all" => [fields[i]]}}).count()
      end
      i += 1
    end
    j = 1
    while (r==0 and j<fields.size)
      # if nothing found and more than one search term
      # start searching for one less search term each time...
      if r == 0
        r = placemarkers.find({"keywords" => {"$all" => fields.sort[0..-(j+1)]}}).count() if (fields.size > 0 and fields.size < 5)
      end
      j += 1
    end
    k=0
    while (r==0 and k < fields.size)
      # if still nothing search for each search term one at a time
      r = placemarkers.find({"keywords" => {"$all" => [fields[k]]}}).count()
      k += 1
    end

    counter += 1
    zc += 1 if r == 0
    #puts counter
    puts "#{counter}:#{r.inspect}:#{fields.inspect}" if r == 0
  end
end
stop = Time.now
puts "#{stop-start} seconds"
puts "#{zc} of #{counter}"

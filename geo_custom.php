#!/usr/bin/php
<?php

//Make a connection to MongoDB server running on your localhost
//use a database "geonames"
//use collection "placemarkers"
$connection = new Mongo();
$db = $connection->geonames;
$placemarkers = $db->placemarkers;
$counter = 0;
$zc = 0;

$start = date("U");
$fh = @fopen("custom_where.csv", "r");
if ($fh) {
  while (($line = fgets($fh, 4096)) !== false) {
    $r=0;
    $line = trim($line);
    $line = str_replace('%2C','+',$line);
    $fields = explode("+",strtolower($line));
    # search for all search terms in the keywords array
    if (count($fields) > 0 and count($fields < 5)) {
      #$r = $placemarkers->count(array('keywords' => array('$all' => sort($fields))));
      $r = $placemarkers->find(array("keywords" => array('$all' => $fields)));
      print "####################\r\n";
      while( $r->hasNext() ) {
          var_dump( $r->getNext() );
      }
    }
    $i=0;
    # sort search terms from longest to shortest
    #$fields.sort! {|x,y| y.size <=> x.size} if fields.size > 0
    #while (r==0 and i < fields.size)
      # if nothing is found and there is more than one search term
      # if there is a zipcode in the search terms
      #if fields[i] == fields[i].to_i.to_s
      #  r = placemarkers.find({"keywords" => {"$all" => [fields[i]]}}).count()
      #end
      #i += 1
    #end
    #j = 1
    #while (r==0 and j<fields.size)
      # if nothing found and more than one search term
      # start searching for one less search term each time...
    #  if r == 0
    #    r = placemarkers.find({"keywords" => {"$all" => fields.sort[0..-(j+1)]}}).count() if (fields.size > 0 and fields.size < 5)
    #  end
    #  j += 1
    #end
    #k=0
    #while (r==0 and k < fields.size)
      # if still nothing search for each search term one at a time
    #  r = placemarkers.find({"keywords" => {"$all" => [fields[k]]}}).count()
    #  k += 1
    #end

    $counter++;
    #puts counter
    #print "$counter:$r:$fields" if r == 0
  }
}
$stop = date("U");
$ttime = $stop-$start;
print "$counter in $ttime seconds\r\n";

?>

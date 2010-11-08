#!/usr/bin/php
<?php

//Make a connection to MongoDB server running on your localhost
//use a database "geonames"
//use collection "placemarkers"
$connection = new Mongo();
$db = $connection->geonames;
$placemarkers = $db->placemarkers;

$placemarkers->ensureIndex(array("loc" => "Mongo::GEO2D"));

$counter = 0;
$no_pc = 0;
$start = date("U");
$fh = @fopen("20k_latitude_longitude.csv", "r");
if ($fh) {
  while (($line = fgets($fh, 4096)) !== false) {
    echo "#######################################\r\n";
    echo $line;
    list($lat, $lng) = explode(",",$line);
    $s = $db->command(
           array(
            'geoNear' => 'placemarkers',
            'near' => array( (float)$lat,(float)$lng ),
            'num' => 1
           )
         );

    var_dump($s);
    
    $counter++;

  }
  if (!feof($fh)) {
    echo "Error: unexpected fgets() fail\n";
  }
  fclose($fh);
}

$stop = date("U");
$ttime = $stop - $start;
print "$counter queries in $ttime seconds";

?>


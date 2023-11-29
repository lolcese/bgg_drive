<?php
$anio = 2019;
$t = time();
$fech = gmdate("Y-m-d H:i",$t);

$pag = file_get_contents('https://www.boardgamegeek.com/');
preg_match("/<div class='support-drive-status-title'>(.*)? Supporters<\/div>/", $pag, $matches);
$matches[1] = str_replace(',','',$matches[1]);

$str = "$fech,$matches[1]\n";

echo "$str\n";
file_put_contents("/home/lilialardone/public_html/temp/drive_$anio.dat", $str, FILE_APPEND);

?>

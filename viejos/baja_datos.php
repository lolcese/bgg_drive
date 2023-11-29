<?php
$anio = 2022;
$t = time();
$fech = gmdate("Y-m-d H:i",$t);

$pag = file_get_contents('https://www.boardgamegeek.com/');
preg_match("/<h3 class='support-drive-status-title'>(.*)? Supporters<\/h3>/", $pag, $matches);
$matches[1] = str_replace(',','',$matches[1]);

$str = "$fech,$matches[1]\n";

echo "$str\n";
file_put_contents("/home/lolcese/bgg_drive/drive_$anio.dat", $str, FILE_APPEND);

?>

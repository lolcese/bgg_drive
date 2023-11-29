<?php
$anio = 2020;
$t = time();
$fech = gmdate("Y-m-d H:i",$t);

$pag = file_get_contents('https://boardgamegeek.com/support/randomblurb');
preg_match("/\"numsupporters\":\"(.*?)\",/", $pag, $matches);
#$matches[1] = str_replace(',','',$matches[1]);

$str = "$fech,$matches[1]\n";

echo "$str\n";
file_put_contents("/home/lilialardone/public_html/temp/drive_$anio.dat", $str, FILE_APPEND);
#file_put_contents("aa.dat",$str,FILE_APPEND);
?>

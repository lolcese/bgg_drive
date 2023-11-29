#! /usr/bin/perl

use File::Fetch;
use File::Copy;

$anio = 2016;
$anio_p = $anio+1;

$dir_prog = 'e:\Luis\Dropbox\bgg\drive';
$dir_web  = 'e:\Luis\Dropbox\bgg\drive\Subir';
$dir_pub  = 'e:\Luis\Dropbox\Public';

my $ff = File::Fetch->new(uri => "http://lolcese.hol.es/drive_$anio.dat");
my $where = $ff->fetch( to => "$dir_prog" );

open (OUT, ">$dir_prog/plot_$anio.pg");
print OUT "
set terminal pngcairo size 800,600 font 'Sans,16'
set output '$dir_prog/bgg_$anio.png'
set object 1 rectangle from screen 0,0 to screen 1,1 fc rgb '#FFFACD' behind

set datafile separator ','

set xdata time
set timefmt '%Y-%m-%d %H:%M'

set xtics font 'Sans,12'
set ytics font 'Sans,12'

set title 'BGG $anio Support drive'
set xlabel 'Day'
set ylabel 'Donors'

set xrange ['$anio-12-01 0:00':'$anio_p-01-01 12:00']
set format x '%d'
set xtics '$anio-12-01',60*60*24*3

set yrange [0:20000]
set ytics 0,2000

set grid
set key right bottom reverse

set label '100% extra gg' at '2016-12-02 00:00',16400 font 'Sans,12'

plot 15869 notitle lt rgb '#228b22' lw 2, \\
     '$dir_prog\\drive_2014.dat' using (timecolumn(1)+2*366*24*60*60):2 title '2014' lt rgb 'blue' pt 7 ps .8, \\
     '$dir_prog\\drive_2015.dat' using (timecolumn(1)+1*366*24*60*60):2 title '2015' lt rgb 'orange' pt 7 ps .8, \\
     '$dir_prog\\drive_2016.dat' using 1:2 title '2016' lt rgb 'red' pt 7 ps .8
";

close(OUT);

system ("gnuplot $dir_prog\\plot_$anio.pg");

copy("$dir_prog\\bgg_$anio.png","$dir_web\\bgg_$anio.png") or die "Copy failed: $!";
copy("$dir_prog\\bgg_$anio.png","$dir_pub\\bgg_$anio.png") or die "Copy failed: $!";

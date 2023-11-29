#! /usr/bin/perl

use File::Fetch;
use File::Copy;

$anio = 2015;

$dir_prog = '/home/lolcese/Dropbox/bgg/drive';
$dir_web  = '/home/lolcese/Dropbox/Apps/site44/lolcese.site44.com';
$dir_pub  = '/home/lolcese/Dropbox/Public';

my $ff = File::Fetch->new(uri => "http://lolcese.hol.es/BGG_drive/drive_$anio.dat");
my $where = $ff->fetch( to => "$dir_prog" );

open (OUT, ">$dir_prog/plot_$anio.pg");
print OUT "
#!/usr/bin/gnuplot

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

set xrange ['$anio-12-01 0:00':'$anio-12-31 23:59']
set format x '%d'
set xtics '$anio-12-01',60*60*24*3

set yrange [0:14000]
set ytics 0,1000

set grid
set key right bottom reverse box

set label '90% extra gg' at '2015-12-02 00:00',9827-170 font 'Sans,10'
set label '100% extra gg' at '2015-12-02 00:00',10919-170 font 'Sans,10'

plot '$dir_prog/drive_2015.dat' using 1:2 title '2015' lt rgb 'red' pt 7 ps .8, \\
     9827 notitle lt rgb '#7CFC00' lw 2, \\
     10991 notitle lt rgb '#228b22' lw 2, \\
     '$dir_prog/drive_2014.dat' using (timecolumn(1)+365*24*60*60):2 title '2014' lt rgb 'blue' pt 7 ps .8
";

close(OUT);

system ("gnuplot $dir_prog/plot_$anio.pg");

copy("$dir_prog/bgg_$anio.png","$dir_web/bgg_$anio.png") or die "Copy failed: $!";
copy("$dir_prog/bgg_$anio.png","$dir_pub/bgg_$anio.png") or die "Copy failed: $!";

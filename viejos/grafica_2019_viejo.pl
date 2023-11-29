#! /usr/bin/perl

use File::Fetch;
use File::Copy;
use Time::localtime;

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);

$year = $year+1900;
$mon += 1;
$mday = sprintf("%02d",$mday);
$hour = sprintf("%02d",$hour);
$min = sprintf("%02d",$min);

$fech = "$year-$mon-$mday $hour:$min UTC";

$anio = 2019;
$anio_p = $anio+1;

# $day_now = 10;
# ($year_now,$month_now,$day_now) = Today(1);
#$dia_2_at = $day_now - 3;
#$dia_2_de = $day_now + 2;

#$dir_prog = '.';
 $dir_prog = '/home/lolcese/bgg_drive';
# $dir_web  = '/root/Dropbox/bgg/drive/Subir';
# $dir_pub  = '/root/Dropbox/Public';

my $ff = File::Fetch->new(uri => "http://lilialardone.com.ar/temp/drive_$anio.dat");
my $where = $ff->fetch( to => "$dir_prog" );

open (OUT, ">$dir_prog/plot_$anio.pg");
print OUT "
#!/usr/bin/gnuplot

set terminal pngcairo size 800,600 font 'Sans,16'
set output '$dir_prog/bgg_$anio.png'
set object 1 rectangle from screen 0,0 to screen 1,1 fc rgb '#FFFFFF' behind

set datafile separator ','

set xdata time
set timefmt '%Y-%m-%d %H:%M'

set xtics font 'Sans,12'
set ytics font 'Sans,12'

set title 'BGG $anio Support drive'
set xlabel 'Day (UTC)'
set ylabel 'Supporters'

set xrange ['$anio-12-01 0:00':'$anio_p-01-01 12:00']
set format x '%d'
set xtics '$anio-12-01',60*60*24*3

set yrange [0:20000]
set ytics 0,2000

set grid
set key right bottom reverse

set label 1 'Generated on $fech'
set label 1 at screen 0.01, 0.98 font 'Sans,10'

plot '$dir_prog/drive_2015.dat' using (timecolumn(1)+365*24*60*60*4+24*60*60*1):2 title '2015' lt rgb '#e0c492'  pt 7 ps .8, \\
     '$dir_prog/drive_2016.dat' using (timecolumn(1)+365*24*60*60*3):2            title '2016' lt rgb '#323d77'  pt 7 ps .8, \\
     '$dir_prog/drive_2017.dat' using (timecolumn(1)+365*24*60*60*2):2            title '2017' lt rgb '#ff0000'  pt 7 ps .8, \\
     '$dir_prog/drive_2018.dat' using (timecolumn(1)+365*24*60*60*1):2            title '2018' lt rgb '#ffce00'  pt 7 ps .8, \\
     '$dir_prog/drive_2019.dat' using 1:2                                         title '2019' lt rgb '#42b0a3'  pt 7 ps .8
";

close(OUT);

system ("gnuplot $dir_prog/plot_$anio.pg");

system ("rclone copy $dir_prog/bgg_2019.png Dropbox:/Public");

#! /usr/bin/perl

use File::Fetch;
use File::Copy;
use Time::localtime;
use Time::Local;

########################################
$anio   = 2021;
$anio_c = 2020;
$goal   = 18000;

# $dir_prog = '.';
$dir_prog = '/home/lolcese/bgg_drive';
########################################

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);

$year = $year+1900;
$mon += 1;
$mday = sprintf("%02d",$mday);
$hour = sprintf("%02d",$hour);
$min = sprintf("%02d",$min);

$fech = "$year-$mon-$mday $hour:$min UTC";

$anio_p = $anio + 1;

# $day_now = 10;
# ($year_now,$month_now,$day_now) = Today(1);
#$dia_2_at = $day_now - 3;
#$dia_2_de = $day_now + 2;

my $ff = File::Fetch->new(uri => "http://lilialardone.com.ar/temp/drive_$anio.dat");
my $where = $ff->fetch( to => "$dir_prog" );

open (IN1,"$dir_prog/drive_$anio.dat");
open (IN2,"$dir_prog/drive_$anio_c.dat");

open (OUT, ">$dir_prog/dife.dat");
@lin_a = <IN1>;
@lin_p = <IN2>;

foreach $l_a (@lin_a) {
  chomp($l_a);
  $enc = 0;
  ($an_a,$me_a,$di_a,$ho_a,$mi_a,$cant_a) = split /[, :-]/, $l_a;
  next if ($cant_a == 0);
  next if ($di_a < 4);
  $me_a--;
  $time_a = timegm(0, $mi_a, $ho_a, $di_a, $me_a, $an_a);
  
  foreach $l_p (@lin_p) {
    chomp($l_p);
    ($an_p,$me_p,$di_p,$ho_p,$mi_p,$cant_p) = split /[, :-]/, $l_p;
    next if ($cant_p == 0);
    $me_p--;
    $time_p = timegm(0, $mi_p, $ho_p, $di_p, $me_p, $an_a);
    if (abs($time_a - $time_p) <= 60*16) {
      $dife = $cant_a - $cant_p;
      $porc = ($cant_a - $cant_p) / $cant_p * 100;
      print OUT "$l_a,$dife,$porc\n";
      last;
    }
  }
}

open (OUT, ">$dir_prog/plot_$anio.pg");
print OUT "
#!/usr/bin/gnuplot

set terminal pngcairo size 1000,750 font 'Sans,16'
set datafile separator ','

set output '$dir_prog/bgg_$anio.png'
set object 1 rectangle from screen 0,0 to screen 1,1 fc rgb '#FFFFFF' behind

set label 'Generated on $fech' at screen 0.985, 0.985 right font 'Sans,10'

set xdata time
set timefmt '%Y-%m-%d %H:%M'

set xtics font 'Sans,12'
set ytics font 'Sans,12'

set xlabel 'Day (UTC)'
set ylabel 'Supporters'

set xrange ['$anio-12-01 0:00':'$anio_p-01-01 12:00']
set format x '%d'
set xtics '$anio-12-01',60*60*24*3

set yrange [0:20000]
set ytics 0,2000

set grid
set key right bottom reverse

set label 'Goal' at '2021-12-02 00:00',18400 font 'Sans,11'

plot $goal notitle lt rgb '#228b22' lw 2, \\
     '$dir_prog/drive_2015.dat' using (timecolumn(1)+365*24*60*60*6+24*60*60*2):2 title '2015' lt rgb '#e0c492'  pt 7 ps .6, \\
     '$dir_prog/drive_2016.dat' using (timecolumn(1)+365*24*60*60*5+24*60*60*1):2 title '2016' lt rgb '#323d77'  pt 7 ps .6, \\
     '$dir_prog/drive_2017.dat' using (timecolumn(1)+365*24*60*60*4+24*60*60*1):2 title '2017' lt rgb '#ff0000'  pt 7 ps .6, \\
     '$dir_prog/drive_2018.dat' using (timecolumn(1)+365*24*60*60*3+24*60*60*1):2 title '2018' lt rgb '#ffce00'  pt 7 ps .6, \\
     '$dir_prog/drive_2019.dat' using (timecolumn(1)+365*24*60*60*2+24*60*60*1):2 title '2019' lt rgb '#42b0a3'  pt 7 ps .6, \\
     '$dir_prog/drive_2020.dat' using (timecolumn(1)+365*24*60*60*1+24*60*60*0):2 title '2020' lt rgb '#ff7062'  pt 7 ps .6, \\
     '$dir_prog/drive_2021.dat' using 1:2                                         title '2021' lt rgb '#ad114c'  pt 7 ps .9

";

close(OUT);

system ("gnuplot $dir_prog/plot_$anio.pg");

system ("rclone copy $dir_prog/bgg_2021.png LuisUNC:bgg_drive");

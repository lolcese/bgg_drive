#! /usr/bin/perl

use File::Fetch;
use File::Copy;
use Time::localtime;

$tm=localtime;
my ($day_now,$month_now,$year_now)=($tm->mday,$tm->mon,$tm->year);

$year_now = $year_now+1900;
$month_now += 1;

$anio = 2018;
$anio_p = $anio+1;

# $day_now = 10;
# ($year_now,$month_now,$day_now) = Today(1);
$dia_2_at = $day_now - 3;
$dia_2_de = $day_now + 2;

$dir_prog = '/root/bgg_drive';
# $dir_web  = '/root/Dropbox/bgg/drive/Subir';
# $dir_pub  = '/root/Dropbox/Public';

my $ff = File::Fetch->new(uri => "http://lilialardone.com.ar/temp/drive_$anio.dat");
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
set xlabel 'Day (UTC)'
set ylabel 'Supporters'

set xrange ['$anio-12-01 0:00':'$anio_p-01-01 12:00']
set format x '%d'
set xtics '$anio-12-01',60*60*24*3

set yrange [0:20000]
set ytics 0,2000

set grid
set key right bottom reverse

plot '$dir_prog/drive_2014.dat' using (timecolumn(1)+1*365*24*60*60*3+366*24*60*60):2 title '2014' lt rgb 'blue'     pt 7 ps .8, \\
     '$dir_prog/drive_2015.dat' using (timecolumn(1)+1*365*24*60*60*2+366*24*60*60):2 title '2015' lt rgb 'orange'   pt 7 ps .8, \\
     '$dir_prog/drive_2016.dat' using (timecolumn(1)+1*365*24*60*60*2):2              title '2016' lt rgb 'red'      pt 7 ps .8, \\
     '$dir_prog/drive_2017.dat' using (timecolumn(1)+1*365*24*60*60*1):2              title '2017' lt rgb '#800080'  pt 7 ps .8, \\
     '$dir_prog/drive_2018.dat' using 1:2                                             title '2018' lt rgb '#009933'  pt 7 ps .8
";

close(OUT);

system ("gnuplot $dir_prog/plot_$anio.pg");

# open (OUT, ">$dir_prog/plot_$anio.pg");
# print OUT "
# #!/usr/bin/gnuplot

# set terminal pngcairo size 800,600 font 'Sans,16'
# set output '$dir_prog/bgg_${anio}_zoom.png'
# set object 1 rectangle from screen 0,0 to screen 1,1 fc rgb '#FFFACD' behind

# set datafile separator ','

# set xdata time
# set timefmt '%Y-%m-%d %H:%M'

# set xtics font 'Sans,12'
# set ytics font 'Sans,12'

# set title 'BGG $anio Support drive'
# set xlabel 'Day (UTC)'
# set ylabel 'Donors'

# set xrange ['2017-12-29 0:00':'2018-01-02 0:00']
# set format x '%d'
# set xtics '$anio-12-01',60*60*24

# # set yrange [0:20000]
# # set ytics 0,2000

# set grid
# set key right bottom reverse

# plot '$dir_prog/drive_2016.dat' using (timecolumn(1)+1*365*24*60*60):2                title '2016' lt rgb 'red'     pt 7 ps .8, \\
#      '$dir_prog/drive_2017.dat' using 1:2                                             title '2017' lt rgb '#800080' pt 7 ps .8
# ";

# close(OUT);

# system ("gnuplot $dir_prog/plot_$anio.pg");

# copy("$dir_prog/bgg_$anio.png","$dir_web/bgg_$anio.png") or die "Copy failed: $!";
# copy("$dir_prog/bgg_$anio.png","$dir_pub/bgg_$anio.png") or die "Copy failed: $!";

# copy("$dir_prog/bgg_${anio}_zoom.png","$dir_web/bgg_${anio}_zoom.png") or die "Copy failed: $!";
# copy("$dir_prog/bgg_${anio}_zoom.png","$dir_pub/bgg_${anio}_zoom.png") or die "Copy failed: $!";

system("rclone copy $dir_prog/bgg_$anio.png Dropbox:bgg/drive/")
# system("rclone sync $dir_prog/bgg_$anio.png Dropbox:Public/")

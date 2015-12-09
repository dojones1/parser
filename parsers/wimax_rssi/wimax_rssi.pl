use strict;
#use diagnostics;
use parser;

# Create a Zip file
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use File::Copy;
use Getopt::Std;
use Data::Dumper;
use Scalar::Util qw( looks_like_number );
use Time::localtime;
use XML::Simple qw(:strict);

my $syntax = qq{

Usage: $0 [-g <GPS logfile> -l <Data Card logfile> | -c <CSV file>] [-d] [-h]

where:
   -g <GPS logfile> is the GPS logfile to parse
   -l <Data card logfile> is the data card logfile to parse
   -c <CSV file> is the combined data to parse
   -d Debug mode
   -h This help screen

};


my $gpslogfile;
my $datalogfile;
my $csvfile;
my $xmlfile;
my $debug   = 0;
my $loc_info;
my $google_info;
my $date;
my $minPower    = 10;           # used to record the max and min powers found in the log
my $maxPower    = -120;
my $maxColPower = -50;          # plot variations of power between this colour range
my $minColPower = -100;
my $maxEdgeTestColPower = -78;  # edge testing colour range
my $minEdgeTestColPower = -89;

parser_set_parser("wimax_rssi");

sub parse_params()
{
    # Are any command line options specified?
    getopts('c:dhg:l:');

    # debug mode
    if( defined $main::opt_d )
    {
        $debug = 1;
        $parser::debug=$debug;
        $main::opt_d = 1;
        print "Debug mode\n" if $debug;
    }

    # Help
    if( defined($main::opt_h) )
    {
        $main::opt_h = 1;
        print $syntax;
        die "\n";
    }

    if( !(defined($main::opt_g) and defined($main::opt_l)) and !defined($main::opt_c) )
    {
        print "Please provide some form of input file\n";
        print $syntax;
        exit(1);
    }

    # GPS Logfile
    if( defined($main::opt_g))
    {
        $gpslogfile = $main::opt_g;
        print "...Opening GPS $gpslogfile\n" if $debug;
        die "Can't find GPS logfile $gpslogfile because $!" unless -f $gpslogfile;
    }

    # Datacard Logfile
    if( defined($main::opt_l))
    {
        $datalogfile = $main::opt_l;
        print "...Opening data card $datalogfile\n" if $debug;
        die "Can't find data card $datalogfile because $!" unless -f $datalogfile;
    }

    # Combined CSV Logfile
    if( defined($main::opt_c))
    {
        $csvfile = $main::opt_c;
        print "...Opening data card $csvfile\n" if $debug;
        die "Can't find data card $csvfile because $!" unless -f $csvfile;
    }

}


sub parse_gps_log()
{
    my $line_num  = 0;
    my $loc_no    = 0;
    my $use_gpgga = 1;  # hard code to use the GPGGA statements
    my $tm = localtime;
    $date = sprintf( "%02d%02d%02d",
                     $tm->mday,
                     $tm->mon+1,
                     ($tm->year+1900)%100 );
    print "Date is $date\n" if $debug;

    parser_open_file($gpslogfile);

    print "...Parsing $gpslogfile\n";

    READLINE:
    foreach( @lines )
    {
        $line_num++;
        chomp;
        my $search_line = $_;

        # print "$search_line\n" if $debug;
        # process a command
        if( $search_line =~ /^\$GPRMC,(\d+)[\d.]*,A,(\d{1,4}\.\d{1,4}),(\w),(\d{1,5}\.\d{1,4}),(\w),[\d.]*,[\d.]*,(\d+),[\d.]*,\w*,?[\w*]+$/gm )
        {
            # print "$search_line\n" if $debug;

            # overwrite todays date with the one from the GPS data file if present
            $date = $6;
            print "GPRMC Date is $date\n" if $debug;

            # ignore this data except for the date if using GPGGA data instead
            if( $use_gpgga == 0 )
            {
                my $time = $1;

                # dateTime (YYYY-MM-DDThh:mm:ssZ)
                # Here, T is the separator between the calendar and the hourly notation of time, and Z indicates UTC. (Seconds are required.)
                # <TimeStamp>
                #  <when>1997-07-16T07:30:15Z</when>
                # </TimeStamp>
                my $when = sprintf( "%4d-%02d-%02dT%02d:%02d:%02dZ",
                                    $date%100+2000,
                                    (int($date/100)) % 100,
                                    int($date/10000),
                                    int($time/10000),
                                    (int($time/100)) % 100,
                                    $time%100 );
                $loc_info->{'loc_no'}{$loc_no}->{'when'}         = $when;

                my $degrees = int($2/100);
                my $minutes = $2-($degrees*100);
                my $latt = $degrees + $minutes/60.0;  # how far north south you are
                # print "deg $degrees min $minutes lat $latt\n";

                # latitutude is +- 90 degrees
                $loc_info->{'loc_no'}{$loc_no}->{'lat'}          = ($3 eq 'N') ? $latt : -$latt;

                $degrees = int($4/100);
                $minutes = $4-($degrees*100);
                my $long = $degrees + $minutes/60.0;  # how far east west you are
                # longitutude is +- 180 degrees
                $loc_info->{'loc_no'}{$loc_no}->{'lon'}          = ($5 eq 'E') ? $long : -$long;

                $loc_info->{'loc_no'}{$loc_no}->{'gps_line_num'} = $line_num;
                $loc_no++;
            }
        }
        elsif(    ($use_gpgga == 1)
               #                                1                 2          3           4           5     6       7                8                9
               && ($search_line =~ /^\$GPGGA,(\d+)[\d.]*,(\d{1,4}\.\d{1,4}),(\w),(\d{1,5}\.\d{1,4}),(\w),([12]),(\d{2}),[\d.]*,(-?\d+\.\d{1,3}),M,(-?\d+\.\d{1,3}),M,[\d.]*,[\w*]+$/gm ) )
        {
            # print "$search_line\n" if $debug;

            # dateTime (YYYY-MM-DDThh:mm:ssZ)
            # Here, T is the separator between the calendar and the hourly notation of time, and Z indicates UTC. (Seconds are required.)
            # <TimeStamp>
            #  <when>1997-07-16T07:30:15Z</when>
            # </TimeStamp>
            my $time = $1;
            # use todays date or the date from the last GPRMC line
            print "GPGGA Date is $date\n" if $debug;
            my $when = sprintf( "%4d-%02d-%02dT%02d:%02d:%02dZ",
                                $date%100+2000,
                                (int($date/100)) % 100,
                                int($date/10000),
                                int($time/10000),
                                (int($time/100)) % 100,
                                $time%100 );
            $loc_info->{'loc_no'}{$loc_no}->{'when'}         = $when;

            my $degrees = int($2/100);
            my $minutes = $2-($degrees*100);
            my $latt = $degrees + $minutes/60.0;  # how far north south you are
            # print "deg $degrees min $minutes lat $latt\n";
            # latitutude is +- 90 degrees
            $loc_info->{'loc_no'}{$loc_no}->{'lat'}          = ($3 eq 'N') ? $latt : -$latt;

            $degrees = int($4/100);
            $minutes = $4-($degrees*100);
            my $long = $degrees + $minutes/60.0;  # how far east west you are
            # longitutude is +- 180 degrees
            $loc_info->{'loc_no'}{$loc_no}->{'lon'}          = ($5 eq 'E') ? $long : -$long;

            # altitude is in meters
            $loc_info->{'loc_no'}{$loc_no}->{'alt'}          = $8;

            $loc_info->{'loc_no'}{$loc_no}->{'gps_line_num'} = $line_num;
            $loc_no++;
        }
    }
    print Dumper \%{$loc_info} if $debug;
}


sub parse_data_log()
{
    my $line_num    = 0;
    my $loc_no      = 0;
    my $match_time  = 0;
    my $offset_min  = 0;
    my $offset_sec  = 0;
    my $first_match = 0;

    parser_open_file($datalogfile);

    print "...Parsing $datalogfile\n";

    READLINE:
    foreach( @lines )
    {
        $line_num++;
        chomp;
        my $search_line = $_;

        #print "$search_line" if $debug;
        # process a command
        if( $search_line =~ /^(\w{3}) (\d{2}) (\d{2}):(\d{2}):(\d{2})\s+RSSI=-(\d+)dBm\s+CINR=(\d+)dB\s+TxPwr=(\d+)dBm/gm )
        {
            # print "$search_line" if $debug;

            my $month = $MONTHS{$1};
            my $day = $2;
            my $hour = $3;
            my $min = $4;
            my $sec = $5;

            # add or subtract the offset to the time
            my $offset = ($hour*60*60) + (($min+$offset_min)*60) + ($sec+$offset_sec);
            $hour = int($offset/3600);
            $min  = int(($offset - $hour*60*60)/60);
            $sec  = $offset%60;

            my $when = sprintf( "%4d-%02d-%02dT%02d:%02d:%02dZ",
                                ($date%100)+2000,
                                $month,
                                $day,
                                $hour,
                                $min,
                                $sec );
            if( $hour > 23 )
            {
                die "Invalid time $when\n";
            }

            if( $first_match == 0 )
            {
                print "\nFirst GPS time logged was        $loc_info->{'loc_no'}{$match_time}->{'when'}\n";
                print "First Data Card time logged was  $when\n";
                print "The two logs may not have started at the same time.\n";
                print "Do you wish to add a min:sec time offset to the data card log? y/(n): ";
                chomp( my $offset_yn=<STDIN> );
                if( $offset_yn =~ /y/i )
                {
                    print "Enter the offset to add to or subtract from the Data Card time in [-]mm:ss\n";
                    chomp( $offset_yn=<STDIN> );
                    if( $offset_yn =~ /(-?)(\d+):(\d+)/ )
                    {
                        if( $1 eq '-' )
                        {
                            $offset_min = -$2;
                            $offset_sec = -$3;
                            print "Subtracting $offset_min:$offset_sec from the Data Card times\n";
                        }
                        else
                        {
                            $offset_min = $2;
                            $offset_sec = $3;
                            print "Adding $offset_min:$offset_sec to the Data Card times\n";
                        }
                        # add or subtract the offset to the time
                        $offset = ($hour*60*60) + (($min+$offset_min)*60) + ($sec+$offset_sec);
                        $hour = int($offset/3600);
                        $min  = int(($offset - $hour*60*60)/60);
                        $sec  = $offset%60;
                        $when = sprintf( "%4d-%02d-%02dT%02d:%02d:%02dZ",
                                         ($date%100)+2000,
                                         $month,
                                         $day,
                                         $hour,
                                         $min,
                                         $sec );
                        print "First Data Card time will now be $when\n\n";
                        print "Press any key to continue....\n";
                        chomp( my $in=<STDIN> );
                    }
                }
                else
                {
                    print "\n";
                }
                $first_match = 1;
            }

            # have we synched the timestamps?
            if(    exists( $loc_info->{'loc_no'}{$match_time}->{'when'} )
                && ( $loc_info->{'loc_no'}{$match_time}->{'when'} eq $when ) )
            {
                my $rssi = -$6;
                $loc_info->{'loc_no'}{$match_time}->{'rssi'} = $rssi;
                print "RSSI power at $when is $rssi\n" if $debug;
                $maxPower = $rssi if( $rssi > $maxPower );
                $minPower = $rssi if( $rssi < $minPower );

                $loc_info->{'loc_no'}{$match_time}->{'cinr'}  = $7;
                $loc_info->{'loc_no'}{$match_time}->{'txpwr'} = $8;
                $loc_info->{'loc_no'}{$match_time}->{'data_line_num'} = $line_num;
                $match_time++;
            }
            else
            {
                # search each location for a matching time
                foreach my $locNo (sort { $a <=> $b; } keys %{$loc_info->{'loc_no'}})
                {
                    if(    exists( $loc_info->{'loc_no'}{$locNo}->{'when'} )
                        && ( $loc_info->{'loc_no'}{$locNo}->{'when'} eq $when ) )
                    {
                        print "Matching $when with locNo $locNo\tat $loc_info->{'loc_no'}{$locNo}->{'when'}\n";
                        my $rssi = -$6;
                        $loc_info->{'loc_no'}{$locNo}->{'rssi'}  = $rssi;
                        print "RSSI power at $when is $rssi\n" if $debug;
                        $maxPower = $rssi if( $rssi > $maxPower );
                        $minPower = $rssi if( $rssi < $minPower );
                        $loc_info->{'loc_no'}{$locNo}->{'cinr'}  = $7;
                        $loc_info->{'loc_no'}{$locNo}->{'txpwr'} = $8;
                        $loc_info->{'loc_no'}{$locNo}->{'data_line_num'} = $line_num;
                        $match_time = $locNo+1;
                        last;
                    }
                }
            }
        }
    }
    print "Max power recorded was $maxPower dBm\n";
    print "Min power recorded was $minPower dBm\n";
    # print Dumper \%{$loc_info} if $debug;
}


sub parse_csv_log()
{
    open CSVFILE, "$csvfile" or die "Could not open $csvfile for reading: $!\n";
    my @csv = <CSVFILE>;
    close CSVFILE;

    my $line_num = 0;
    my $loc_no   = 0;

    foreach my $line ( @csv )
    {
        #print "Line: $line\n";

        $line_num++;
        next unless $line_num>1;    # skip first line

        my @data = split(/,/, $line);

        my ($date, $time, $lat, $long) = @data[0..3];
        my ($rssi, $cinr, $txpwr)      = @data[7..9];

        next if( !defined($long) and !defined($lat) );
        next if( ($long == 0) and ($lat == 0));
        next if( ($rssi > 100) or ($rssi < -200) );

        # dateTime (YYYY-MM-DDThh:mm:ssZ)
        # Here, T is the separator between the calendar and the hourly notation of time, and Z indicates UTC. (Seconds are required.)
        # <TimeStamp>
        #  <when>1997-07-16T07:30:15Z</when>
        # </TimeStamp>
        $date =~ /(\d+) (\w+) (\d+)/;
        my $when = sprintf( "%4d-%02d-%02dT", $3, $MONTHS{$2}, $1 );
        $time =~ /(\d+):(\d+):(\d+)/;
        $when .= sprintf( "%02d:%02d:%02dZ", $1, $2, $3 );
        $loc_info->{'loc_no'}{$loc_no}->{'when'}         = $when;

        # latitutude is +- 90 degrees
        $loc_info->{'loc_no'}{$loc_no}->{'lat'}          = $lat;

        # longitutude is +- 180 degrees
        $loc_info->{'loc_no'}{$loc_no}->{'lon'}          = $long;

        # altitude is in meters
        $loc_info->{'loc_no'}{$loc_no}->{'alt'}          = 0;
        $loc_info->{'loc_no'}{$loc_no}->{'gps_line_num'} = $line_num;
        $loc_info->{'loc_no'}{$loc_no}->{'rssi'}         = $rssi;
        print "RSSI power at $when is $rssi at lon $long lat $lat on line $line_num\n" if $debug;

        $maxPower = $rssi if( $rssi > $maxPower );
        $minPower = $rssi if( $rssi < $minPower );

        $loc_info->{'loc_no'}{$loc_no}->{'cinr'}         = $cinr;
        $loc_info->{'loc_no'}{$loc_no}->{'txpwr'}        = $txpwr;
        $loc_info->{'loc_no'}{$loc_no}->{'data_line_num'}= $line_num;
        $loc_no++;
    }

    print "Max power recorded was $maxPower dBm\n";
    print "Min power recorded was $minPower dBm\n";
}


# remove the redundant locations that do not have rssi data
sub remove_redundant_data()
{
    my $loc_no      = 0;
    foreach my $locNo( sort { $a <=> $b; } keys %{$loc_info->{'loc_no'}} )
    {
        if( !exists( $loc_info->{'loc_no'}{$locNo}->{'rssi'} ) )
        {
            # print Dumper \%{$loc_info->{'loc_no'}{$locNo}};
            delete($loc_info->{'loc_no'}{$locNo});
        }
    }
}



# google colours go intensity blue green red
# html colours go red green blue
sub set_power_colours()
{
    print "\nAre you Edge Testing? y/(n) ";
    chomp( my $offset_yn=<STDIN> );
    if( $offset_yn =~ /y/i )
    {
        $maxColPower = $maxEdgeTestColPower; # zoom in to plot finer variations of power
        $minColPower = $minEdgeTestColPower; # between this colour range
        print "Displaying colour variations in the fine range $minColPower dBm to $maxColPower dBm\n";
    }
    else
    {
        print "Displaying colour variations in the wide range $minColPower dBm to $maxColPower dBm\n";
    }

    # search each location
    foreach my $locNo (sort { $a <=> $b; } keys %{$loc_info->{'loc_no'}})
    {
        # set the colour Blue Green Red in the range 100-255 for a roughly linear response
        if( exists($loc_info->{'loc_no'}{$locNo}->{'rssi'}) )
        {
            if( $loc_info->{'loc_no'}{$locNo}->{'rssi'} > 10 )
            {
                $loc_info->{'loc_no'}{$locNo}->{'colour'}  = 'FF0F0F0F'; # error is grey
                $loc_info->{'loc_no'}{$locNo}->{'rgb_col'} = '0F0F0F';
            }
            elsif( $loc_info->{'loc_no'}{$locNo}->{'rssi'} >= -120 )
            {
                # theoretical range is -120 to +10dBm so 130 dBm
                # colour starts with 100% red and finished with 100% green with blue banding
                # intensity is not changed
                my $colour = calc_google_colour( $loc_info->{'loc_no'}{$locNo}->{'rssi'} );
                $loc_info->{'loc_no'}{$locNo}->{'colour'} = sprintf("%08X", $colour);

                # now create the same html rgb colour
                $loc_info->{'loc_no'}{$locNo}->{'rgb_col'} = calc_rgb_colour( $colour );
            }
            else
            {
                $loc_info->{'loc_no'}{$locNo}->{'colour'}  = 'FF0F0F0F'; # error is grey
                $loc_info->{'loc_no'}{$locNo}->{'rgb_col'} = '0F0F0F';
            }
        }
    }
    print Dumper \%{$loc_info} if $debug;
}


sub calc_google_colour($)
{
    my $rssi = shift;
    my $col;
    my $colour = 0xFF000000;    # this is the base luminosity, FF = 100%

    # theoretical range is -120 to +10dBm so 130 dBm
    # colour range used is maxColPower - minColPower
    my $range = $maxColPower - $minColPower;

    # gives a value in the range minColPower to maxColPower
    if( $rssi > $minColPower )
    {
        if( $rssi > $maxColPower )
        {
            $col = 0xFF;        # max value
        }
        else
        {
            $col = $rssi - $minColPower;
            $col = int(($col/$range)*0xFF);     # use full range of colours
            $col = 0xFF if( $col>0xFF );        # limit range to 0 to 255
        }
    }
    else
    {
        $col = 0;               # min value
    }

    # colour starts with 100% green and finished with 100% red with blue banding
    # intensity is not changed
    $colour += ($col % 42) * 0x10000;   # blue banding
    $colour += $col        * 0x100;     # green
    $colour += (0xFF-$col) * 0x1;       # red

    return( $colour );
}


sub calc_rgb_colour($)
{
    my $col = shift;
    $col = ($col & 0xFF00) / 0x100;     # green portion is $col
    my $colour;

    # now create the same html rgb colour as the google colour
    $colour  = (0xFF - $col) * 0x10000; # red
    $colour += $col * 0x100;            # green
    $colour += $col % 42;               # blue banding

    return( sprintf("#%06X\;", $colour) );
}


sub create_google_info()
{
    my $last_locNo = -1;
    my $altIsPower = 1;

    if( !defined($csvfile) )
    {
        print "\nSet the altitude to the RSSI power level? (y)/n ";
        chomp( my $offset_yn=<STDIN> );
        if( $offset_yn =~ /n/i )
        {
            $altIsPower = 0;
            print "No\n\n";
        }
        else
        {
            print "Yes\n\n";
        }
    }

    # create the legend
    $google_info->{'Folder'}{0}->{'name'}                                             = 'Legend: RSSI (dBm)';
    $google_info->{'Folder'}{0}->{'open'}                                             = 1;
    $google_info->{'Folder'}{0}->{'visibility'}                                       = 1;                       # html colours are red green blue

    my $pwr;
    my $j = 0;
    for( my $i=20; $i >= -120; $i -= 20 )
    {
        $pwr = ( $i==20 ) ? 10 : $i;   # change the highest point to +10dBm

        # print a legend close to the range of values that we have
        if( ($pwr+10 >= $minPower) && ($pwr-10 <= $maxPower) )
        {
            my $pwrTxt = ($pwr>=0) ? sprintf("+%3d",$pwr) : sprintf("%3d",$pwr);
            my $colTxt = calc_google_colour($pwr);
            $colTxt = calc_rgb_colour($colTxt);
            $google_info->{'Folder'}{0}->{'Placemark'}{$j}->{'name'} = '<![CDATA[<b><span style="color:'.$colTxt.'">'.$pwrTxt.'</span></b>]]>';
            # print "i=$i j=$j pwr=$pwr col=$colTxt\n";
            $j++;
        }
    }

    # search each location
    foreach my $locNo (sort { $a <=> $b; } keys %{$loc_info->{'loc_no'}})
    {
        # pick only those with a valid match of both logs
        if( exists($loc_info->{'loc_no'}{$locNo}->{'rssi'}) )
        {
            # ignore the first valid data point
            if( $last_locNo > -1 )
            {
                my $name = sprintf("Pt_%06d", $locNo);
                my $id = $name;

                # now write the actual data
                $google_info->{'Folder'}{1}->{'name'}                                             = 'Data points';
                $google_info->{'Folder'}{1}->{'open'}                                             = 0;
                $google_info->{'Folder'}{1}->{'visibility'}                                       = 1;
                $google_info->{'Folder'}{1}->{'Placemark'}{$name}->{'name'}                       = "<![CDATA[<span style=\"color:$loc_info->{'loc_no'}{$locNo}->{'rgb_col'}\">$name</span>]]>";
                print "RSSI power at $name is $loc_info->{'loc_no'}{$locNo}->{'rssi'}\n" if $debug;
                $google_info->{'Folder'}{1}->{'Placemark'}{$name}->{'description'}                = "<![CDATA[RSSI = <span style=\"color:$loc_info->{'loc_no'}{$locNo}->{'rgb_col'}\">$loc_info->{'loc_no'}{$locNo}->{'rssi'}</span> dBm  \
                                                                                                     <br>CINR = $loc_info->{'loc_no'}{$locNo}->{'cinr'} dB \
                                                                                                     <br>TxPwr= $loc_info->{'loc_no'}{$locNo}->{'txpwr'} dBm \
                                                                                                     <br>$loc_info->{'loc_no'}{$locNo}->{'when'} \
                                                                                                     <br>GPS log <a href=\"$gpslogfile.html#L$loc_info->{'loc_no'}{$locNo}->{'gps_line_num'}\">line $loc_info->{'loc_no'}{$locNo}->{'gps_line_num'}</a> \
                                                                                                     <br>Data log <a href=\"$datalogfile.html#L$loc_info->{'loc_no'}{$locNo}->{'data_line_num'}\">line $loc_info->{'loc_no'}{$locNo}->{'data_line_num'}</a>]]>";

                $google_info->{'Folder'}{1}->{'Placemark'}{$name}->{'LineString'}{'extrude'}      = 1;

                if( $altIsPower == 1 )
                {
                    # set altitude as absolute level relative to -120 dBm
                    my $groundlevel = -100; # power at ground level - was $minPower;
                    my $last_rssi = $loc_info->{'loc_no'}{$last_locNo}->{'rssi'} - $groundlevel;
                    my $rssi      = $loc_info->{'loc_no'}{$locNo}->{'rssi'}      - $groundlevel;
                    if( ($rssi < 0) || ($last_rssi < 0) ) # make below groundlevel points visible
                    {
                        $google_info->{'Folder'}{1}->{'Placemark'}{$name}->{'LineString'}{'altitudeMode'} = 'clampToGround';
                    }
                    else
                    {
                        $google_info->{'Folder'}{1}->{'Placemark'}{$name}->{'LineString'}{'altitudeMode'} = 'relativeToGround';
                    }
                    $google_info->{'Folder'}{1}->{'Placemark'}{$name}->{'LineString'}{'coordinates'}  = "$loc_info->{'loc_no'}{$last_locNo}->{'lon'},$loc_info->{'loc_no'}{$last_locNo}->{'lat'},$last_rssi  $loc_info->{'loc_no'}{$locNo}->{'lon'},$loc_info->{'loc_no'}{$locNo}->{'lat'},$rssi";
                }
                else
                {
                    $google_info->{'Folder'}{1}->{'Placemark'}{$name}->{'LineString'}{'altitudeMode'} = 'clampToGround'; # 'absolute';
                    $google_info->{'Folder'}{1}->{'Placemark'}{$name}->{'LineString'}{'coordinates'}  = "$loc_info->{'loc_no'}{$last_locNo}->{'lon'},$loc_info->{'loc_no'}{$last_locNo}->{'lat'},$loc_info->{'loc_no'}{$last_locNo}->{'alt'}  $loc_info->{'loc_no'}{$locNo}->{'lon'},$loc_info->{'loc_no'}{$locNo}->{'lat'},$loc_info->{'loc_no'}{$locNo}->{'alt'}";
                }

                $google_info->{'Folder'}{1}->{'Placemark'}{$name}->{'LineString'}{'tessellate'}   = 1;
                $google_info->{'Folder'}{1}->{'Placemark'}{$name}->{'Style'}{$id}{'LineStyle'}{'color'} = $loc_info->{'loc_no'}{$locNo}->{'colour'};
                $google_info->{'Folder'}{1}->{'Placemark'}{$name}->{'Style'}{$id}{'LineStyle'}{'colorMode'} = 'normal';
                $google_info->{'Folder'}{1}->{'Placemark'}{$name}->{'Style'}{$id}{'LineStyle'}{'width'} = 4;
                $google_info->{'Folder'}{1}->{'Placemark'}{$name}->{'Timestamp'}{'when'}          = $loc_info->{'loc_no'}{$locNo}->{'when'};
            }
            $last_locNo = $locNo;
        }
    }
    # $google_info->{'creator'}    = 'Mark Hind';
    $google_info->{'name'}       = $xmlfile;
    $google_info->{'visibility'} = 1;
    $google_info->{'open'}       = 1;
    # print Dumper \%{$google_info} if $debug;
}


# main program

# read command line options
parse_params();

if( -f $gpslogfile and -f $datalogfile )
{
    print "...Parsing GPS log file $gpslogfile\n";
    parse_gps_log();

    print "...Parsing Data Card log file $datalogfile\n";
    parse_data_log();
}
elsif( -f $csvfile )
{
    parse_csv_log();
    $datalogfile=$csvfile;
}
else
{
    print "No data to parse\n";
    exit(1);
}


set_power_colours();
create_google_info();

# create XML and KML file names
$xmlfile = parser_rm_file_ext($PARSER_CONFIG{'ext'}, $datalogfile).'xml';
my $kmlfile = parser_rm_file_ext($PARSER_CONFIG{'ext'}, $datalogfile).'kml';
my $kmzfile = parser_rm_file_ext($PARSER_CONFIG{'ext'}, $datalogfile).'kmz';

print "...Writing GPS logfile $gpslogfile to\n   KML file $kmlfile\n";
print "...Building KML file $kmlfile\n";
# XML header
my $decl = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
$decl   .= "<kml xmlns=\"http://earth.google.com/kml/2.1\">";

my $out = XMLout( \%{$google_info},
                  NoAttr     => 1,             # Do not represent hash key/values as nested elements
                  NoEscape   => 1,             # Do not suppress escaping of html control characters
                  AttrIndent => 1,             # Attributes printed one-per-line with sensible indentation
                  KeyAttr    =>['name','id'],
                  RootName   => "Document",    # Root element will be name
                  XMLDecl    => "$decl");      # start with the XML declaration
$out .= "\</kml\>\n";

print "...Writing KML File: $kmlfile\n";
# workaround for XML Simple to remove the style names
#study( $out );
$out =~ s/\<Style\>(\s*)\<name\>(.*)\<\/name\>/\<Style\>/gm;
print "...Fixed Style-Name problem\n";
open KMLFILE,">$kmlfile" or die "Could not open KML file $kmlfile for writing: @!";
print "...Opened KMLFILE\n";
print KMLFILE $out;
print "...Written to KMLFILE\n";
close KMLFILE;

# remove invalid (no rssi data) locations
remove_redundant_data();

# now create the XML file
print "...Building XML file $xmlfile\n";
$decl    = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
$decl   .= "<!-- $PARSER_CONFIG{'name'} Log Parser output -->\n";
$decl   .= "<!-- Written by Alastair Kinross -->\n";
$decl   .= "<wimax_data rssi_log=\"$datalogfile\" gps_log=\"$gpslogfile\" kml_file=\"$kmlfile\">";
$out  = XMLout( \%{$loc_info},
                NoAttr     => 0,         # Do not represent hash key/values as nested elements
                NoEscape   => 1,         # Do not suppress escaping of html control characters
                AttrIndent => 1,         # Attributes printed one-per-line with sensible indentation
                KeyAttr    =>['name','id'],
                RootName   => "", # Root element will be name
                XMLDecl    => "$decl");  # start with the XML declaration
$out .= "\</wimax_data\>\n";

open OUTFILE,">$xmlfile" or die "Could not open XML file $xmlfile for writing: @!";
print OUTFILE $out;
close OUTFILE;

# zip up the kml file as a kmz file
my $zip = Archive::Zip->new();
# add the kml file from disk
my $file_member = $zip->addFile( $kmlfile );

# Save the kmz file
if( $zip->writeToFileNamed($kmzfile) == AZ_OK )
{
    # successful so its OK to delete the kml file
    unlink $kmlfile;
    print "...Created KMZ file $kmzfile\n";
}
else
{
    die "Could not write KMZ file $kmzfile: $!\n";
}


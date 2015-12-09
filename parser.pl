#!/usr/bin/perl

# Log Parser
# Created by Donald Jones
# 13th Oct 2006

use strict;
use warnings;
#use diagnostics;
use lib ('parsers/pkgs');
use Data::Dumper;
use File::Copy;
use File::Basename;
use Getopt::Std;
use parser;
use msc_parser;
use vars qw( $opt_c $opt_d $opt_g $opt_h $opt_l $opt_p $opt_x);

my $syntax = qq{

Usage: $0 -p <parser> [-l <logfile> | -x <xmlfile>] [-g logfile] [-d] [-h]

where:
\t-p <parser> parser to be use
\t-g <logfile> is the GPS logfile to parse
\t-l <logfile> is the logfile to parse
\t-x <xmlfile> is the xmlfile to display (the parser is not re-run)
\t-d Debug mode
\t-h This help screen

};

my $csvfile;
my $gpslogfile;
my $logfile;
my $xmlfile;
my $logfiledir;
my $debug = 0;

$PARSER="";

sub parse_params
{
    # Are any command line options specified?
    getopts('c:dhg:l:p:x:');

    # debug mode
    if( defined($opt_d) )
    {
        $debug = 1;
        $parser::debug=$debug;
        $opt_d = 1;
        print "Debug mode\n" if $debug;
    }

    # Help
    if( defined($opt_h) )
    {
        $opt_h = 1;
        print $syntax;
        my @parsers = sort(parser_get_parsers());
        my $pars = join( "\n\t", @parsers );
        print "The parsers available are:\n\n\t$pars\n";
        die "\n";
    }

    # Parser
    if( defined($opt_p) )
    {
        parser_set_parser($opt_p);
    }
    else
    {
        print $syntax;
        die "Parser required\n";
    }

    # GPS Logfile
    if( defined($opt_g) )
    {
        $gpslogfile = $opt_g;
        print "Opening GPS Logfile: $gpslogfile\n" if $debug;
        # check GPS logfile exists
        die "Can't find $gpslogfile because $!" unless -f $gpslogfile;
    }

    # Combined CSV Logfile
    if( defined($opt_c) )
    {
        $csvfile = $opt_c;
        print "...Opening combined CSV file: $csvfile\n" if $debug;
        die "Can't find combined CSV file $csvfile because $!" unless -f $csvfile;
    }

    # Need to ensure that either an XML or Log file is provided.
    if( !defined $opt_l and !(defined $opt_x or defined $opt_c) )
    {
        print $syntax;
        die "Please specify an input file\n";
    }

    # Check for mutual exclusive on logfile and xml file
    if( defined $opt_l and defined $opt_x )
    {
        print $syntax;
        die "Can't specify both a Log file AND an XML file together\n";
    }

    # Logfile
    if( defined($opt_l) )
    {
        $logfile = $opt_l;
        print "Opening Logfile: $logfile\n" if $debug;
        # check logfile exists
        die "Can't find $logfile because $!" unless -f $logfile;
    }

    # XMLfile
    if( defined($opt_x) )
    {
        $xmlfile = $opt_x;
        print "Opening XMLfile: $xmlfile\n" if $debug;
        # check logfile exists
        die "Can't find $xmlfile because $!" unless -f $xmlfile;
    }
}

sub record_user_stats()
{
    use LWP::Simple;


    my $who = getlogin() || (getpwuid($<))[0] || "Kilroy";
    print "User: $who $PARSER\n" if $debug;

    my $output;
    my $url = "http://10.128.36.3/cgi-bin/parser/upload.pl?user=$who&tool=parser&tool2=$PARSER";
    print "URL: $url\n" if $debug;
    unless( defined( $output = get($url) ) )
    {
        print "Unable to get $url\n";
    }
    print $output if $debug;
}

sub parser_create_output(@) {
   my @outputs = @_;
   my $filestub;
   $filestub = parser_rm_file_ext($PARSER_CONFIG{'ext'},$logfile) if defined $logfile;
   $filestub = parser_rm_file_ext($PARSER_CONFIG{'ext'},$xmlfile) if defined $xmlfile;

   my $num_splits = parser_get_num_splits($xmlfile);

   my %copied_files;

   foreach my $output (@outputs)
   {
       my $ext = $output->{'ext'};
       my $index = 0;
       my $num_events;

       # Handle Generation of output by exe file
       if( exists $output->{'exe'} )
       {
           my $exe = $output->{'exe'};
           print "\nExe: $exe\n";
           print "XML: $xmlfile\n";

           if( exists $output->{'split'} )
           {

               while( $index < $num_splits )
               {
                   my $cmd = "\"$exe\" -s $index \"$xmlfile\"";
                   qx($cmd);
                   $index++;
               }
           }
           else
           {
               my $cmd = "\"$exe\" \"$xmlfile\"";
               print "CMD: $cmd\n";
               qx($cmd);
           }
       }

       # Handle Generation of output by XSL file
       #print Dumper $output;
       my $params = "";

       if( exists $output->{'xsl'} )
       {
           my $xsl = $output->{'xsl'};
           if( exists $output->{'split'} )
           {
               $index = 0;
               while( $index < $num_splits )
               {
                   $params = "index=$index";
                   parser_conv_xml_via_xsl($xmlfile, $xsl, $ext, $index++, $params);
               }
           }
           else
           {
               parser_conv_xml_via_xsl($xmlfile, $xsl, $ext, undef, undef);
           }
       }

       # Overcome issue with msxsl.exe which results in rogue xmlns attributes for nodes
       if( exists $output->{'strip_xmlns'} )
       {
           my $tmpfile = $filestub.$ext;
           if( exists $output->{'split'} )
           {
               $index = 0;
               while( $index < $num_splits )
               {
                   $tmpfile = $filestub.$index."_$ext";
                   strip_xmlns($tmpfile);
                   $index++;
               }
           }
           else
           {
               strip_xmlns($tmpfile);
           }

       }

       foreach my $file (keys %{$output->{'file'}})
       {
           # Only copy files the first time that they occur.
           if( !exists($copied_files{$file}) )
           {
               print "...Copying $file to $logfiledir\n";
               copy($file, $logfiledir) or print "Copy of $file failed: $!";
               $copied_files{$file} = "";  # Record the fact that we have copied the file
               #my $cmd = "CACLS \"$logfiledir/$file\" /E /P Everyone:F";
               my $cmd = "ATTRIB -R \"$logfiledir\\$file\"";
               #print "Cmd: $cmd\n";
               print qx($cmd);
           }
       }
   }
}

sub strip_xmlns($)
{
    my $tmpfile = shift;
    print "...Strip xmlns=\"\" from $tmpfile\n";
    open INFILE,"$tmpfile" or die "Could not open $tmpfile for reading: @!";
    my @lines = <INFILE>;
    close( INFILE );

    my @newsvg;
    foreach my $line (@lines)
    {
        #print "Line: $line\n";
        #chomp;
        $line =~ s/xmlns=\"\"//;
        #print "$newline\n";
        push( @newsvg, $line );
    };

    open( TMPOUTFILE, ">$tmpfile" ) or die "Could not open $tmpfile for writing: @!";
    print TMPOUTFILE @newsvg;
    close( TMPOUTFILE );
}

# main program
parse_params();

my $dbfile = 'database.xml';

record_user_stats();

# Only call the parser if the user provided a logfile
if( !defined $xmlfile )
{
    my $logdir         = dirname($logfile);
    my $logbase        = basename($logfile);
    my $logbasenoext   = $logbase;
    $logbasenoext      = parser_rm_file_ext(undef,basename($logfile)) if $logbasenoext =~ /\./;
    $logbasenoext      =~ s/\.$//;
    $logbasenoext      =~ s/\.\\//;

    my $newlogdir = "$logdir\\$logbasenoext"."_$PARSER";

    # Create new directory
    if( ! -d $newlogdir )
    {
        my $err = mkdir( $newlogdir) unless -f $newlogdir;

        if( $err )
        {
            $err = $!;
            if(     ( $err )
                && !(    ( $err =~ /File exists/i )
                      || ( $err =~ /No such file or directory/i ) )
              )
            {
               die "Unable to create directory \"$newlogdir\" : $err\n";
            }
        }
    }

    # Copy log file to new directory
    copy($logfile, $newlogdir) or print "Copy of $logfile failed: $!";
    $logfile = "$newlogdir\\$logbase";

    if( defined($gpslogfile) )
    {
        # Copy gps log file to new directory
        copy($gpslogfile, $newlogdir) or print "Copy of $gpslogfile failed: $!";
        my $gpslogbase = basename($gpslogfile);
        $gpslogfile = "$newlogdir\\$gpslogbase";
    }

    if( defined($csvfile) )
    {
        # Copy gps log file to new directory
        copy($csvfile, $newlogdir) or print "Copy of $csvfile failed: $!";
        my $csvbase = basename($csvfile);
        $csvfile = "$newlogdir\\$csvbase";
    }

    my $parser_cmd = "parsers\\$PARSER";
    print "$PARSER:\n   $PARSER_CONFIG{'desc'}\n";
    $parser_cmd .= "\\".$PARSER_CONFIG{'pl'};
    $parser_cmd .= " -c \"$csvfile\"" if( defined($csvfile) );
    $parser_cmd .= " -g \"$gpslogfile\"" if( defined($gpslogfile) );
    $parser_cmd .= " -l \"$logfile\"" if( defined($logfile) );
    $parser_cmd .= " -d " if $debug;
    print "cmd: $parser_cmd";
    system($parser_cmd);
}

print Dumper $PARSER_CONFIG{'output'} if $debug;

print "...Generating tagged version of log file\n";
parser_gen_tagged_log($gpslogfile) if( defined($gpslogfile) );
parser_gen_tagged_log($logfile) if( defined($logfile) ); # Do not create this if we were are processing XML files

$xmlfile = parser_rm_file_ext($PARSER_CONFIG{'ext'},$logfile)."xml" unless (defined($xmlfile) or defined($csvfile) );

# Populate the logfiledir;
$logfile =~ /([\S\s]+)\\/ if( defined($logfile) );
$xmlfile =~ /([\S\s]+)\\/ if( defined($xmlfile) );
$logfiledir = $1;
print "Logfile: $logfile\n" if $debug;
print "XMLfile: $xmlfile\n" if $debug;

# Process any output types
if (exists $PARSER_CONFIG{'output_type'})
{
    my $output_type = $PARSER_CONFIG{'output_type'};
    if( exists $PARSER_XML_CONFIG->{'output_type'}->{$output_type} )
    {
        parser_create_output(@{$PARSER_XML_CONFIG->{'output_type'}->{$output_type}->{'output'}});
    }
    else
    {
        print "Could not find output_type: $output_type config\n";
    }
}

#process any specific output formats
parser_create_output(@{$PARSER_CONFIG{'output'}}) if exists $PARSER_CONFIG{'output'};


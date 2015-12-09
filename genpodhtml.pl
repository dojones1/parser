#!/usr/bin/perl

# Set up search paths for Perl modules.
use Data::Dumper;
use strict;
use File::Find;
my $rootdir = "U:\\parser";
my $html_path = "$rootdir\\html\\";

sub process_filename {
   shift;
   s/\//\\/g;
   s/^\.\\//g;
   return $_;
}

sub process_file {
   return unless -f;
   return unless /\.pl$/ or /\.pm$/;
   my $file = $_;
   my $infile = process_filename($File::Find::name);

   my $outfile = $html_path.process_filename($file).".html";

   print "\nFile: $File::Find::name\n";
   print "Infile:  $infile\n";
   print "Outfile: $outfile\n";

   my $cmd = "pod2html --infile $infile --outfile $outfile --css=Active.css --index --title $file --quiet";
   print "Cmd: $cmd\n";
   system($cmd);
   die unless -e $outfile;
}


my @DIRLIST = ($rootdir);
find(\&process_file, @DIRLIST);
#my $cmd = "pod2html --podroot=$rootdir --htmldir=$html_path --css=Active.css --index --recurse --verbose";
#print "Cmd: $cmd\n";
#system($cmd);
   

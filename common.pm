#!/usr/bin/perl -w
# Ted Sluis 2015-12-20
# Filename : common.pm
#===============================================================================
# common sub routines 
#===============================================================================
package common;
use strict;
use warnings;
use POSIX qw(strftime);
use Time::Local;
use Getopt::Long;
use File::Basename;
#===============================================================================
# Read configfile
my %config;
sub READCONFIG(@) {
	shift;
	# config file name:
	my $config = shift;
	# full scriptname:		
	my $fullscriptname = shift;
        my $scriptname  = basename($fullscriptname);
        my $directoryname = dirname($fullscriptname);
	# path to config file
	$config = $directoryname.'/'.$config;
	print "\nReading parameters and values from '$config' config file:\n";
	if (!-e $config) {
		print "Can not read config! Config file '$config' does not exists!\n";
		exit 1;
	} elsif (!-r $config) {
		print "Can not read config! Config file '$config' is not readable!\n";
		exit 1;
	} else {
		my @cmd = `cat $config`;
		my $section;
		foreach my $line (@cmd) {
			chomp($line);
			# skip lines with comments:
			next if ($line =~ /^\s*#/);
			# skip blank lines:
			next if ($line =~ /^\s*$/);
			# Get section:
			if ($line =~ /^\s*\[([^\]]+)\]\s*(#.*)?$/) {
				$section = $1;
				print "\nSection: [$section]\n" if (($section =~ /common/) || ($scriptname =~ /$section/));
				next;
			} elsif ($line =~ /^([^=]+)=([^\#]*)(#.*)?$/) {
				# Get paramter & value
				my $parameter = $1;
				my $value = $2;
				# remove any white spaces at the begin and the end:
				$parameter =~ s/^\s*|\s*$//g;
				$value     =~ s/^\s*|\s*$//g;
				if ((!$parameter) || ($parameter =~ /^\s*$/)) {
					print "The line '$line' in config file '$config' is invalid! No parameter specified!\n";
					exit 1;
				}
				if ((!$section) || ($section =~ /^\s*$/)) {
					print "The line '$line' in config file '$config' is invalid! No section specified jet!\n";
					exit 1;
				}
				# save section, parameter & value
				next unless (($section =~ /common/) || ($scriptname =~ /$section/));
				$config{$section}{$parameter} = $value;
				print "   $parameter = $value\n";
			} else {
				# Invalid line:
				print "The line '$line' in config file '$config' is invalid!\n";
				print "Valid lines looks like:\n";
				print "# comment line\n";
				print "[some_section_name]\n";
				print "parameter=value\n";
				print "Comment text (started with #) behind a section or parameter=value is allowed!";
				exit 1;
			}
		}
	}
	print "\n";
	return %config;
}
1;

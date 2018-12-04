#!/usr/bin/perl

#*********************************************************************************
# FileName: filter.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-19
# Description: This code is to remove some faseq containing too many unknown 
#              or repeated characters.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

if (@ARGV!=5) {
	die "	Usage: perl $0 <infile> <outfile> <rmfile> <mincp> <minlen>\n";
}
my $infile=shift;
my $outfile=shift;
my $rmfile=shift;
my $mincp=shift;
my $minlen=shift;

my $unknown=0;
my $repeated=0;
my $short=0;

$/=">";
open OUT,">$outfile" or die "Can't open '$outfile': $!";
open RM,">$rmfile" or die "Can't open '$rmfile': $!";
open IN, "$infile" or die "Can't open '$infile': $!";
<IN>;
while(my $line=<IN>){
	chomp $line;
	my ($name,$seq)=(split(/\n/,$line,2))[0,1];
	#print "$name\n$seq\n";last;
	my $newseq=$seq;
	$seq=~s/\s+//g;
	my $len=length $seq;
	my $flag=0;
=cut
	if ($seq=~/([^ATCGatgc])/g) {
		$flag=1;
		$unknown++;
	}
	if ($seq=~/((A){$mincp,}|(T){$mincp,}|(G){$mincp,}|(C){$mincp,})/g) {
		$flag=1;
		$repeated++;
	}
=cut

	if ($len<$minlen) {
		$flag=1;
		$short++;
	}

	if ($flag==0) {
		print OUT ">$name\n$newseq";
	}else {
		print RM ">$name\n$newseq";
	}
}

print "unknown: $unknown\nduplicate: $repeated\nshort: $short\n";
close IN;
close RM;
close OUT;
$/="\n";

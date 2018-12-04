#!/usr/bin/perl

#*****************************************************************************
# FileName: merged_2_fa.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-19
# Description: This code is to get the strand of the biggest group, then print 
#              the faseq to output file according to the strands.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#Usage:
#    perl $0 <list> <outdir>
#*****************************************************************************

use strict;
use warnings;

if (@ARGV!=3) {
	die "	Usage: perl $0 <merged> <dbfa> <out>\n";
}
my $merged=$ARGV[0];
my $dbfa=$ARGV[1];
my $out=$ARGV[2];
my ($name,$strain,%mark,%big);
my $i=0;
my $max=0;
open MERGED, "$merged" or die "Can't open '$merged': $!";
while (<MERGED>) {
	chomp;
	my ($name,$strain)=(split/\s+/,$_)[0,1];
	$mark{$name}=$strain;
	if ($i==0) {
		$i++;
	}elsif ($i!=0 && $_!~/^>/) {
		$i++;
	}elsif ($i!=0 && $_=~/^>/) {
		if ($i>$max) {
			$max=$i;
			$i=0;
			%big=%mark;
			%mark=();
		}
	}
}
close MERGED;

$/=">";
open DBFA, "$dbfa" or die "Can't open '$dbfa': $!";
open OUT, ">$out" or die "Can't open '$out': $!";
<DBFA>;
while (my $line=<DBFA>) {
	chomp $line;
	my ($token,$seq)=(split /\n/,$line,2)[0,1];
	if (exists $big{$token}) {
		if ($big{$token} eq "+") {
			$seq=~s/\s+//g;
			print OUT ">$token\n$seq\n";
		}elsif ($big{$token} eq "-") {
			$seq=~s/\s+//g;
			$seq=~ tr/ACGTacgt/TGCAtgca/;
			$seq=reverse ($seq);
			print OUT ">$token\n$seq\n";
		}
	}
}
close OUT;
close DBFA;

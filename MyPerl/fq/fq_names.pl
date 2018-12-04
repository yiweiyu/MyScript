#!/usr/bin/perl

#*********************************************************************************
# FileName: fq_names.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2018-01-03
# Description: This code is to get the fq names in given fqfiels.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

if (@ARGV!=2) {
	die "	Usage: perl $0 <input> <output>\n";
}
my $in=shift;
my $out=shift;
open (IN, "$in") or die "Can not open $in: $!\n";
open (OUT,">$out")|| die"Can't open $out: $!\n";
my $n=1;
while (my $line=<IN>) {
	#@TTGCGGCATGCG:MN00129:22:000H2C37L:1:11101:17569:1075 1:N:0:4
	#GAAGGTGCCATCATTCTTGAGGAGGAAGTAGCGTGGCCGCCAGGTCTTGATGTACT
	#+
	#FAFFAFFFFFFFFFFFFAFFFFFFFFFFAFFAFFFFFFFFFFFFFFFFFFFFFFFF
	chomp $line;
	if ($n%4==1) {
		if ($line=~/^@.{12}:(.*) /) {
			my $name=$1;
			print OUT "$name\n";
		}else {
			print "error: line $n\n";
			exit;
		}
	}
	$n++;
}
close IN;
close OUT;


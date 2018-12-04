#!/usr/bin/perl

#*********************************************************************************
# FileName: name2sam.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-9
# Description: This code is to get sam record based on the given name and the input 
#              sam file.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

if (@ARGV!=3) {
	die "	Usage: perl $0 <in_samfile> <in_name> <out>\n"
}
my $in=$ARGV[0];
my $name=$ARGV[1];
my $out=$ARGV[2];
open (SAM, $in) or die "Can not open $in: $!\n";
open (OUT, ">$out") or die "Can not open $out\n";
while (my $line=<SAM>) {
	chomp $line;
	if ($line=~/^@/ | $line=~/^\s+$/) {
		next;
	}
	#E00509:81:HF7YCALXX:4:1101:15260:6056   0       chr1_120286478_120286652_PHGDH  1       42      43M     *       0       0       TGTGCCAACCAGGAGTTTCTTCTATTTCCAGGCCTCCTGGCAG     IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII     AS:i:0  XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:43 YT:Z:UU
	#E00509:81:HF7YCALXX:4:1101:20730:7198   0       chr19_55525684_55525851_GP6     1       24      51M     *       0       0       GTTTCACAGGCTGATCTTGTTTTTTAATGTGAAGGGAAGCGGGCAACGTGC     IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII     AS:i:-12        XN:i:0  XM:i:2  XO:i:0  XG:i:0  NM:i:2  MD:Z:3G19C27    YT:Z:UU
	my $temp=(split /\t/ , $line)[0];
	if ($temp eq $name) {
		print OUT "$line\n";
		last;
	}
}
close SAM;
close OUT;

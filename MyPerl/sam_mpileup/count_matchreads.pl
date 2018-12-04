#!/usr/bin/perl -w

#*****************************************************************************
# FileName: count_nonfusion.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-9-15
# Description: This code is to count the sum of reads not containning fusion.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 <sam> <out>
USAGE
if (@ARGV!=2) {
	die $usage;
}
my $sam=shift;
my $out=shift;

open SAM, $sam or die "Can't open '$sam': $!\n";
my (%hash,$all,@arr);
while (my $line=<SAM>) {
	chomp $line;
	if ($line=~/^\@/ | $line=~/^\s+$/) {
		if ($line=~/^\@SQ/) {
			my $sq_info=(split/\s+/,$line)[1];
			my $sq_name=(split/:/,$sq_info)[1];
			push @arr,$sq_name;
		}
		next;
	}
	#MN00129:11:000H23NKW:1:11102:19803:15901;1:N:0:10       0       chr17_41234373_41234605_BRCA1_exon11    101     0       128M18I5M       *       0       0       GTCACTTATGATGGAAGGGTAGCTGTTAGAAGGCTGGCTCCCATGCTGTTCTAACACAGCTTCTAGTTCAGCCATTTCCTGCTGGAGCTTTATCAGGTTATGTTGCATGGTATCCCTCTGCTTCAAAAACGATAAATGGCACCAAGAAAAT IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII AS:i:-71        XN:i:0  XM:i:2  XO:i:1  XG:i:18 NM:i:20 MD:Z:129C0G2    YT:Z:UU
	#MN00129:11:000H23NKW:1:11102:17039:17882;1:N:0:10       0       chr17_41234373_41234605_BRCA1_exon11    101     42      71M     *       0       0       GTCACTTATGATGGAAGGGTAGCTGTTAGAAGGCTGGCTCCCATGCTGTTCTAACACAGCTTCTAGTTCAG IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII AS:i:0  XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:71 YT:Z:UU
	my ($chr,$start,$rmap,$Tlen)=(split /\t/ , $line)[2,3,5,8];
	#if ($rmap!~/M/) {
	if ($Tlen==0) {
		next;
	}
	$hash{$chr}++;
	$all++;
}
close SAM;

open OUT,">",$out or die "Can't open '$out': $!\n";
print OUT "all\t$all\n";
foreach my $i (@arr) {
	if (exists $hash{$i}) {
		print OUT "$i\t$hash{$i}\n";
	}else {
		print OUT "$i\t0\n";
	}
}
close OUT;

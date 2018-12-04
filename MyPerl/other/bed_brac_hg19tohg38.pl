#!/usr/bin/perl

#*****************************************************************************
# FileName: bed_brac_hg19tohg38.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Description: This code is to convert snp_indel of hg19 to snp_indel of hg38.
# Create Time: 2018-10-15
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0
#*****************************************************************************
use strict;
use warnings;
use File::Basename qw(basename dirname);

if (@ARGV!=2) {
	die "\tUsage: $0 <in> <out>\n";
}
my $in=shift;
my $out_prefix=shift;

open IN,"$in" || die "Can't open '$in': $!\n";
open OUT,">$out_prefix\_hg38.xls" or die "Can't open '$out_prefix\_hg38.xls': $!\n";
while (my $line=<IN>) {
	#chr17	41226515	41226515
	#chr13	32914137	32914137
	chomp $line;
	if ($line=~/^(C|c)hr\s+/ or $line=~/^$/) {
		next;
	}
	my @a=split/\t/,$line;
	my ($chr,$start,$stop)=@a[0,1,2];
	if ($chr=~/17$/) {
		$start+=1847983;
		$stop+=1847983;
	}elsif ($chr=~/13$/) {
		$start-=574137;
		$stop-=574137;
	}
	($a[0],$a[1],$a[2])=($chr,$start,$stop);
	print OUT (join "\t", @a)."\n";
}
close IN;
close OUT;

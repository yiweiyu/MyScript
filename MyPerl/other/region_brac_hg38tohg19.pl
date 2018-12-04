#!/usr/bin/perl

#*****************************************************************************
# FileName: bed_brac_hg38tohg19.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Description: This code is to convert snp_indel of hg38 to snp_indel of hg19.
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
open OUT,">$out_prefix\_hg19.xls" or die "Can't open '$out_prefix\_hg19.xls': $!\n";
while (my $line=<IN>) {
	#chr17_43056940_43057063 124     25      24      20.16   19.35
	#chr17_43063790_43063911 122     23      21      18.85   17.21
	chomp $line;
	if ($line=~/^(C|c)hr\s+/ or $line=~/^$/) {
		next;
	}
	my @a=split/\t/,$line;
	my ($chr,$start,$stop)=(split/_/,$a[0])[0,1,2];
	if ($chr=~/17$/) {
		$start-=1847983;
		$stop-=1847983;
	}elsif ($chr=~/13$/) {
		$start+=574137;
		$stop+=574137;
	}
	my $hg19_pos="$chr\_$start\_$stop";
	print OUT "$hg19_pos\t".(join "\t", @a)."\n";
}
close IN;
close OUT;

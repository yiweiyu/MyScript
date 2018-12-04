#!/usr/bin/perl

#*********************************************************************************
# FileName: sam_flag_info.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-10-16
# Description: This code is to parse the given flag value of sam file.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 <input_Flag> <output_FlagInfo>
USAGE

if (@ARGV!=2) {
	die $usage;
}
my $in=shift;
my $out=shift;

my %hash=(
	0=>"1: template having multiple segments in sequencing",
	1=>"2: each segment properly aligned according to the aligner",
	2=>"4: segment unmapped",
	3=>"8: next segment in the template unmapped",
	4=>"16: SEQ being reverse complemented",
	5=>"32: SEQ of the next segment in the template being reversed",
	6=>"64: the first segment in the template",
	7=>"128: the last segment in the template",
	8=>"256: secondary alignment",
	9=>"512: not passing quality controls",
	10=>"1024: PCR or optical duplicate",
	11=>"2014: supplementary alignment",
);
my %mark;
open IN,$in || die "Can't open $in: $!\n";
open OUT,">$out" || die "Can't open $out: $!\n";
while (my $line=<IN>) {
	chomp $line;
	my $flag=(split/\s+/,$line)[0];
	if (exists $mark{$flag}) {
		next;
	}
	$mark{$flag}=1;
	print OUT "$flag\n";
	#my $flag_b=sprintf "%012b",$flag;
	my $flag_b=sprintf "%b",$flag;
	my @array=split//,$flag_b;
	@array=reverse @array;
	foreach my $i (0..$#array) {
		if ($array[$i]==1) {
			print OUT "\t$hash{$i}\n";
		}
	}
}
close IN;
close OUT;

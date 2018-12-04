#!/usr/bin/perl

#*********************************************************************************
# FileName: MaybeFusion_from_sam.double.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-10-18
# Description: This code is to find probable fusion reads from sam file.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 <input_sam> <output_name>
USAGE

if (@ARGV!=2) {
	die $usage;
}
my $in=shift;
my $out=shift;

my %flaginfo=(
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

my (%discord);
open IN,$in || die "Can't open $in: $!\n";
while (my $line=<IN>) {
	#MN00129:11:000H23NKW:1:23110:15829:20165        81      chr8_38314733_38315293  223     42      149M    =       227     149     TCCTCCACATCCCAGTTCTGCAGTTAGAGGTTGGTGACAAGGCTCCACATCTCCATGGATACTCCACAGTGAGCTCGATCCTCCTTTTCAAACTGACCCTGAGGAAAGGAAAAAAACCCCAAAAGTTAGGAGGGTCTAGGTAGGGGAGG   FFFFFFFFFFFFFFFFFFFF/FFFFFFFFFFFFFFFFFFFFFFFF/FFFFFFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFFFFFFFFFFFFFFF=FFFFFAFFFFFFFFFA   AS:i:-10        XN:i:0  XM:i:2  XO:i:0  XG:i:0  NM:i:2  MD:Z:0A0G147    YS:i:0  YT:Z:DP
	#MN00129:11:000H23NKW:1:23110:15829:20165        161     chr8_38314733_38315293  227     42      128M    =       223     -149    CCACATCCCAGTTCTGCAGTTAGAGGTTGGTGACAAGGCTCCACATCTCCATGGATACTCCACAGTGAGCTCGATCCTCCTTTTCAAACTGACCCTGAGGAAAGGAAAAAAACCCCAAAAGTTAGGAG        FFAFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF/FFFFFFFFFFFFF6FFFF/FFFFFFF=FFFFFFFFFFFFFFFFFFFFFAF/FFFFFFFFFFFFFFFF//FAFFFA=FF=/A=FF6        AS:i:0  XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:128        YS:i:-10        YT:Z:DP
	if ($line=~/^@/) {
		next;
	}
	chomp $line;
	my ($read,$flag,$ref,$pos,$cigar)=(split/\t/,$line)[0,1,2,3,5];
	my $flag_b=sprintf "%012b",$flag;
	my @array=split//,$flag_b;
	@array=reverse @array;
	my ($end,$orient);
	if ($array[6]==1) {
		$end='R1';
		if ($array[4]==1) {
			$orient="L";
		}else {
			$orient="R";
		}
	}elsif ($array[7]==1) {
		$end='R2';
		if ($array[4]==1) {
			$orient="L";
		}else {
			$orient="R";
		}
	}
	if ($array[0]==1) {
		if ($cigar eq "*") {
			push @{$discord{$read}{$end}},"*";
		}else {
			push @{$discord{$read}{$end}},"$ref\_$pos\_$cigar\_$orient";
		}
	}elsif ($array[1]==0) {
		if ($cigar eq "*") {
			push @{$discord{$read}{$end}},"*";
		}else {
			push @{$discord{$read}{$end}},"$ref\_$pos\_$cigar\_$orient";
		}
	}
}
close IN;

open S,">$out.single" || die "Can't open $out.single: $!\n";
open D,">$out.double" || die "Can't open $out.double: $!\n";
open V,">$out.vague" || die "Can't open $out.vague: $!\n";
foreach my $key (keys %discord) {
	my @R1_map=@{$discord{$key}{'R1'}};
	my @R2_map=@{$discord{$key}{'R2'}};
	my $sum=@R1_map+@R2_map;
	if ($sum==2) {
		if ($R1_map[0] eq "*" and $R2_map[0] eq "*") {
			print D "$key\_R1\t@R1_map\n";
			print D "$key\_R2\t@R2_map\n";
		}elsif ($R1_map[0] ne "*" and $R2_map[0] ne "*") {
			my @arr1=split /_/,$R1_map[0];
			my @arr2=split /_/,$R2_map[0];
			if ($arr1[0] eq $arr2[0]) {
				my $long=abs($arr1[1]-$arr2[1]);
				if ($long<10000) {
					next;
				}
			}
			print V "$key\_R1\t@R1_map\n";;
			print V "$key\_R2\t@R2_map\n";
		}else {
			print S "$key\_R1\t@R1_map\n";
			print S "$key\_R2\t@R2_map\n";
		}
	}else {
		if (@R1_map%2==0 and @R2_map%2==0) {
			print D "$key\_R1\t@R1_map\n";
			print D "$key\_R2\t@R2_map\n";
		}elsif (@R1_map==1 and @R2_map%2==0) {
			print S "$key\_R1\t@R1_map\n";
			print S "$key\_R2\t*\n";
		}elsif (@R1_map%2==0 and @R2_map==1) {
			print S "$key\_R1\t*\n";
			print S "$key\_R2\t@R2_map\n";
		} 
	}
}
close S;
close D;
close V;

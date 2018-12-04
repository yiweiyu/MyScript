#!/usr/bin/perl

#*********************************************************************************
# FileName: useful_name_from_sam.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-6
# Description: This code is to get the names of useful reads from input sam files ,
#              then print them to output file.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 <input_sam> <input_refnames,> <output>
USAGE

if (@ARGV!=3) {
	die $usage;
}
my $sam=shift;
my $refname=shift;
my $out=shift;

my %hash;
my @want=split/,/,$refname;
foreach my $i (@want) {
	$hash{$i}=1;
}

open IN,$sam || die "Can't open $sam: $!\n";
open OUT,">$out" || die "Can't write '$out': $!\n";
my %mark;
while (my $line=<IN>) {
	chomp $line;
	#@HD     VN:1.0  SO:unsorted
	#@SQ     SN:chr19_42788849_42799128_CIC  LN:10279
	if ($line=~/^\@[A-Z]{2}/ or $line=~/^$/) {
		next;
	}
	#E00509:81:HF7YCALXX:8:1101:20750:1995   4       *       0       0       *       *       0       0       CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC  IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII  YT:Z:UU
	#E00509:81:HF7YCALXX:8:1101:19076:3454   0       chrX_76763743_77041578_ATRX     174776  42      35M     *       0       0       TCCTGCTCACCTCTTTGAGGATTGCTAGCATTTCA     IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII     AS:i:0  XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:35 YT:Z:UU

	my @lines=(split/\s+/,$line);
	my $readname=$lines[0];
	my $ref=$lines[2];
	if (exists $hash{$ref}) {
		if (!exists $mark{$readname}) {
			print OUT "$readname\n";
			$mark{$readname}=1
		}
	}
}
close IN;
close OUT;

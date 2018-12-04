#!/usr/bin/perl -w

#*****************************************************************************
# FileName: mt_merge_from_sam.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-12-18
# Description: This code is to merge mt.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 <sam> <out_prefix>
USAGE
if (@ARGV!=2) {
	die $usage;
}
my $sam=shift;
my $out_prefix=shift;

open SAM, $sam or die "Can't open '$sam': $!\n";
my (%hash,%mark,%pre_start);
while (my $line=<SAM>) {
	chomp $line;
	if ($line=~/^@/ or $line=~/^\s+$/) {
		next;
	}
	#AGCATACAAGGC:MN00129:11:000H23NKW:1:23110:8842:20127    99      chr7_116411672_116412207        241     42      84M     =       241     -84     GTGAATTAGTTCGCTACGATGCAAGAGTACACACTCCTCATTTGGATAGGCTTGTAAGTGCCCGAAGTGTAAGCCCAACTACAG    FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF    AS:i:0  XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:84 YS:i:0  YT:Z:CP
	#AGCATACAAGGC:MN00129:11:000H23NKW:1:23110:8842:20127    147     chr7_116411672_116412207        241     42      84M     =       241     -84     GTGAATTAGTTCGCTACGATGCAAGAGTACACACTCCTCATTTGGATAGGCTTGTAAGTGCCCGAAGTGTAAGCCCAACTACAG    FFFFFFFFFAFFFFFFFFFFFFFFFFFFFFFFFFFFFAFFFFFFFFFFFFFFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF    AS:i:0  XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:84 YS:i:0  YT:Z:CP
	my ($name,$ref,$start,$Tlen)=(split /\t/ , $line)[0,2,3,8];
	if ($Tlen==0) {
		next;
	}
	unless (exists $mark{$name}) {
		$pre_start{$name}=$start;
		$mark{$name}=1;
		next;
	}
	my $pos;
	if ($start<$pre_start{$name}) {
		$pos=$start;
	}else {
		$pos=$pre_start{$name};
	}
	my $mt=(split /:/ , $name)[0];
	$hash{"$ref\_$pos"}{$mt}=1;
}
close SAM;

my %merge;
foreach my $key (sort keys %hash) {
	my @mts=keys $hash{$key};
	my $begin=pop @mts;
	push @{$merge{$key}{$begin}},$begin;
	delete $hash{$key}{$begin};
	my $n=1;
	while ($n) {
		my @temp_mts=keys $hash{$key};
		if (@temp_mts==0) {
			last;
		}
		foreach my $item (@temp_mts) {
			my @arr1=split//,$item;
			my $flag=0;
			foreach my $entry (keys $merge{$key}) {
				my $count;
				my @temp=@{$merge{$key}{$entry}};
				foreach my $e (@temp) {
					my @arr2=split//,$e;
					$count=0;
					foreach my $i (0..$#arr2) {
						if ($arr1[$i] ne $arr2[$i]) {
							$count++;
						}
						if ($count>2) {
							last;
						}
					}
					if ($count>2) {
						last;
					}
				}
				if ($count>2) {
					next;
				}else {
					$flag=1;
					push @{$merge{$key}{$entry}},$item;
					delete $hash{$key}{$item};
				}
			}
			if ($flag==0) {
				push @{$merge{$key}{$item}},$item;
				delete $hash{$key}{$item};
			}
		}
	}
}
open OUT,">","$out_prefix.merged.mt"
	or die "Can't open '$out_prefix.merged.mt': $!\n";
foreach my $key (sort keys %merge) {
	print OUT "$key\n";
	foreach my $subkey (sort keys $merge{$key}) {
		my @temp=@{$merge{$key}{$subkey}};
		print OUT "\t".(join "\t",@temp)."\n";
	}
}
close OUT;


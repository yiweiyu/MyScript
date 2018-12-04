#!/usr/bin/perl

#*****************************************************************************
# FileName: findhalf.m8.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-8-31
# Description: This code is to find read which halfly maps to ref
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 
					<in> <out> <min_iden> <min_len> <max_len>
USAGE
if (@ARGV!=5) {
	die $usage;
}
my $in=shift;
my $out=shift;
my $min_iden=shift;
my $min_len=shift;
my $max_len=shift;

open IN, "$in" or die "Can't open '$in': $!";
open OUT, ">$out" or die "Can't open '$out': $!";
my $cwq="";
my $cws="";
my $info="";
my $n=0;
while (my $line=<IN>) {
	#MN00129:11:000H23NKW:1:11102:22653:1061;1:N:0:8 1_alk.site.cut.fa       100.00  11      0       0       15      25      66      56      0.013   22.3
	my ($Query_name,$Sbjct_name)=(split/\s+/,$line)[0,1];
	if ($n==0) {
		$n++;
		$cwq=$Query_name;
		$cws=$Sbjct_name;
		$info.=$line;
	}else {
		if ($Query_name eq $cwq and $Sbjct_name eq $cws) {
			$info.=$line;
		}elsif ($Query_name eq $cwq and $Sbjct_name ne $cws) {
			my @w=split/\n/,$info;
			my @want=sort @w;
			my $mark=0;
			my $print="";
			foreach my $i (@want) {
				my ($identity,$real_len)=(split/\s+/,$i)[2,3];
				if ($real_len>$max_len) {
					$mark=1;
					last;
				}
				if ($identity<$min_iden or $real_len<$min_len) {
					next;
				}
				$print.="$i\n";
			}
			if ($mark==0) {
				print OUT "$print";
			}
		}elsif ($Query_name ne $cwq) {
			my @w=split/\n/,$info;
			my @want=sort @w;
			my $mark=0;
			my $print="";
			foreach my $i (@want) {
				my ($identity,$real_len)=(split/\s+/,$i)[2,3];
				if ($real_len>$max_len) {
					$mark=1;
					last;
				}
				if ($identity<$min_iden or $real_len<$min_len) {
					next;
				}
				$print.="$i\n";
			}
			if ($mark==0) {
				print OUT "$print";
			}
			$info="";
			$info.=$line;
			$cwq=$Query_name;
			$cws=$Sbjct_name;
		}
	}
}

			my @w=split/\n/,$info;
			my @want=sort @w;
			my $mark=0;
			my $print="";
			foreach my $i (@want) {
				my ($identity,$real_len)=(split/\s+/,$i)[2,3];
				if ($real_len>$max_len) {
					$mark=1;
					last;
				}
				if ($identity<$min_iden or $real_len<$min_len) {
					next;
				}
				$print.="$i\n";
			}
			if ($mark==0) {
				print OUT "$print";
			}

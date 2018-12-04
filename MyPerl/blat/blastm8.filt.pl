#!/usr/bin/perl

#*****************************************************************************
# FileName: fusion.twosites.all.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-8-22
# Description: This code is to screen input based on given argument (the input 
#              is the output of blast_m8).
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 
					<in> <out> <min_iden> <min_len>
USAGE
if (@ARGV!=4) {
	die $usage;
}
my $in=shift;
my $out=shift;
my $min_iden=shift;
my $min_len=shift;

open IN, "$in" or die "Can't open '$in': $!";
open OUT, ">$out" or die "Can't open '$out': $!";
my $n=0;
my (%all,%filter,%want);
while (my $line=<IN>) {
	#MN00129:5:000H2725C:1:11101:16923:1071;1:N:0:1  FusionID171     100.00  13      0       0       26      38      149     137     0.088   26.3
	chomp $line;
	my @temp=split/\s+/,$line;
	my $Query_name=$temp[0];
	my $Sbjct_name=$temp[1];
	my $identity=$temp[2];
	my $real_len=$temp[3];
	$all{$Query_name}=1;
	if ($identity<$min_iden or $real_len<$min_len) {
		$filter{$Query_name}=0;
		next;
	}
	$want{$Query_name}=1;
	print OUT "$line\n";
}
close IN;
close OUT;

my $s=0;
my $m=0;
while (my ($key,$value)=each %want) {
	if (exists $filter{$key}) {
		delete $filter{$key};
	}
}
my @al=keys %all;
my $a=@al;

my @filt=keys %filter;
my $f=@filt;

my @wa=keys %want;
my $w=@wa;

my $info=join " ",$in,$min_iden,$min_len;
$info.="\nall reads\t$a\nfilter reads\t$f\nwant reads\t$w\n";
print "$info";

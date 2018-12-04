#!/usr/bin/perl

#*********************************************************************************
# FileName: fq12_pair_ornot.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2018-03-09
# Description: This code is to find fq1 fq2 whether pair or not.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
# ModifyList:
#    Revision: V1.1
#    Modifier: Zhang Shehuan <zhangshehuan@celloud.cn>
#    ModifyTime: 2018-06-12
#    ModifyReason: allow _1 _2;
#*********************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 <input_fq1> <input_fq2> <output>
USAGE

if (@ARGV!=3) {
	die $usage;
}
my $fq1=shift;
my $fq2=shift;
my $out=shift;

open OUT,">$out.no" || die "Can't write $out.no: $!\n";
open IN, $fq1 || die "Can't open $fq1: $!\n";
open IN2, $fq2 || die "Can't open $fq2: $!\n";
my ($seq,$plus,$qual,$seq2,$plus2,$qual2);
my $n=0;
while (my $line=<IN>) {
	#@MN00129:11:000H23NKW:1:11102:16153:1054 1:N:0:8
	#TNGTTTAAGATGAGTCATCTTTGTGGGTTTTCATTTTAAATTTTCTTTCTCTAGGTGAAGCTGTACTTCACAAAAACAGTAGAGGAGCCGTCAAATCCAGAGGCTAGCAGTTCAACTTCTGTAACACCAGATGTTAGTGACAATGAACCT
	#+
	#A#AAAFAJJ<FJFA-FFFJJFJJJJJJ<FJJ<JFJJJ<F-<FJJAJJJJ-7F-FFJJFFJJJJJJJJJJJJJJJJF-J<FJJJJF-AFJJFJJJFJJJJJFJFFJJJ7JJJJAJAJJJJJJJJAAJFFFJAFFJJJJFFAJ7A<FJJ---
	chomp (my $line2=<IN2>);
	$n++;
	if ($n%4==1) {
		if ($line=~/^@(.*) / and $line2=~/^@($1) /) {
			chomp $line;
			my $name=$1;
		}elsif ($line=~/^@(.*)_\d/ and $line2=~/^@($1)_\d/) {
			chomp $line;
			my $name=$1;
		}else {
			print OUT "$n:\n\tr1: $line\nr2: $line2\n\n";
		}
	}
}
close IN;
close IN2;
close OUT;


#!/usr/bin/perl

#*********************************************************************************
# FileName: givennum_2_randomfq.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-5
# Description: This code is to get random fq records based on the input numbers 
#              and the input parent fq files.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 <input_number> <input_all> <input_fq1> <input_fq2> <output>
USAGE

if (@ARGV!=5) {
	die $usage;
}
my $num=$ARGV[0];
my $all=$ARGV[1];
my $fq1=$ARGV[2];
my $fq2=$ARGV[3];
my $out=$ARGV[4];

my %want=&createRandNum($all,$num);

my ($line,$seq,$plus,$qual);
open OUT,">$out.R1.fq" || die "Can't write $out.1.fq: $!\n";
open IN, $fq1 || die "Can't open $fq1: $!\n";
my $n=0;
while ($line=<IN>) {
	#@E00509:81:HF7YCALXX:7:1101:20659:1836 1:N:0:CACCTG
	#TNGTTTAAGATGAGTCATCTTTGTGGGTTTTCATTTTAAATTTTCTTTCTCTAGGTGAAGCTGTACTTCACAAAAACAGTAGAGGAGCCGTCAAATCCAGAGGCTAGCAGTTCAACTTCTGTAACACCAGATGTTAGTGACAATGAACCT
	#+
	#A#AAAFAJJ<FJFA-FFFJJFJJJJJJ<FJJ<JFJJJ<F-<FJJAJJJJ-7F-FFJJFFJJJJJJJJJJJJJJJJF-J<FJJJJF-AFJJFJJJFJJJJJFJFFJJJ7JJJJAJAJJJJJJJJAAJFFFJAFFJJJJFFAJ7A<FJJ---
	if ($n>$all*4) {
		last;
	}
	if ($line=~/^@/) {
		chomp $line;
		if (exists $want{$n}) {
			$seq=<IN>;
			chomp $seq;
			$plus=<IN>;
			chomp $plus;
			$qual=<IN>;
			chomp $qual;
			print OUT "$line\n$seq\n$plus\n$qual\n";
		}
		$n++;
	}
}
close IN;
close OUT;

open OUT,">$out.R2.fq" || die "Can't write $out.2.fq: $!\n";
open IN, $fq2 || die "Can't open $fq2: $!\n";
$n=0;
while ($line=<IN>) {
	#@E00509:81:HF7YCALXX:7:1101:20659:1836 2:N:0:CACCTG
	#TGGTGTCAGAATATCTATAATGATCAGGTTCATTGTCACTAATATCTGGTGTTACAGAAGTTGAGCTGCTAGCCTCTGGATTTGACGGCTCCTCTACTGTTTTTGTGAAGTACAGCTTCACCTAGAGAAAGAAAATTTAAAATGAAAACC
	#+
	#AAFFFJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJAJJJJ7-<FJJJJJJFJJJFJJ7FJJJ--<FJAAJJJJJJFJJJFJJJFJJJJFJJJJJFJJJJJJJJJJJJAJ-77<A<FJFFFJJAFFJFJJJ<F<FJF<<AF-<A-AAFF7
	if ($n>$all*4) {
		last;
	}
	if ($line=~/^@/) {
		chomp $line;
		if (exists $want{$n}) {
			$seq=<IN>;
			chomp $seq;
			$plus=<IN>;
			chomp $plus;
			$qual=<IN>;
			chomp $qual;
			print OUT "$line\n$seq\n$plus\n$qual\n";
		}
		$n++;
	}
}
close IN;
close OUT;

sub createRandNum {
	my ($MaxNum,$MaxCount) = @_;
	my $i = 0;
	my %rand = ();
	my $no;
	while (1) {
		$no = int(rand($MaxNum));
		if (!$rand{$no}) {
			$rand{$no} = 1;
			$i++;
		}
		if ($i >= $MaxCount) {
			last;
		}
	}
	return %rand;
}

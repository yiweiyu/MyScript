#!/usr/bin/perl

#*********************************************************************************
# FileName: wholefq_to_r1r2.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2018-05-10
# Description: This code is to convert fastq file to fastq1 file and fastq2 file.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

if (@ARGV!=2) {
	die "	Usage: perl $0 <input> <out_prefix>\n";
}
my $in=shift;
my $out=shift;
open (IN, "$in") or die "Can not open $in: $!\n";
open (R1, ">$out\_R1.fastq") or die "Can not write '$out\_R1.fastq': $!\n";
open (R2, ">$out\_R2.fastq") or die "Can not write '$out\_R1.fastq': $!\n";
my $n=1;
my ($name,$seq,$plus,$qual,$end);
while (my $line=<IN>) {
#@MN00129:3:000H22KYJ:1:11101:14202:1055 1:N:0:1
#AACTCCTACGGAAGGCAGCAGTGATAAACCTTTAGCAATAAACCAAAGTTTAACTAAGCCATACTAACCCCAGGGTTGGTCAATTTCGTGCCAGCCACCGCGGTCACACGATTAACCCAAGTCAATAGAAACCGGCATAAAGAGTGTTTTAGATCAATTCCCCTCAATAAAGCTAAAATTCACGTGAGTTGTAAAAAACTCCAGTTGATACAAAATAAACTACGAAAGTGGCTTTAATGCATCT
#+
#AAAFFFFCGC?GE?2AEFGHHFHGHHGHHHHHHHHHHHHHGHHHEHEHHHHFHHHGBFHGHHGHHGHHHHGGGGF2?@EEHHGHHHHHHEGGHEFGHHHEEGGA/EFFH?EGHGGHHHGEHHHHFHFDFHHGA<@CGDFHBFGGFHFGFFGCGGGBGHHHHHHGG.GHHHBDHHHGFHGHHHGFGEEGHGFFF0C:0BGGEFFGGFGBCBFF09.BF0;BF0/9E.AA/9/A.FBB99B//;BF
	chomp $line;
	if ($n%4==1) {
		if ($line!~/^\@/) {
			die "fastq error: line $n: '$line'!\n";
		}
		$name=$line;
		my $endinfo=(split/\s+/,$name)[1];
		$end=(split/:/,$endinfo)[0];
	}elsif ($n%4==2) {
		$seq=$line;
	}elsif ($n%4==3) {
		if ($line!~/^\+/) {
			die "fastq error: line $n: '$line'!\n";
		}
		$plus=$line;
	}elsif ($n%4==0) {
		$qual=$line;
		if ($end==1) {
			print R1 "$name\n$seq\n$plus\n$qual\n";
		}elsif ($end==2) {
			print R2 "$name\n$seq\n$plus\n$qual\n";
		}
	}
	$n++;
}
close IN;
close R1;
close R2;


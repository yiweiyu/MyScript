#!/usr/bin/perl

#*********************************************************************************
# FileName: fq2fa.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-7-11
# Description: This code is to convert fastq file to fasta file.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

if (@ARGV!=2) {
	die "	Usage: perl $0 <input> <output>\n";
}
my $in=shift;
my $out=shift;
open (IN, "$in") or die "Can not open $in: $!\n";
open (OUT, ">$out") or die "Can not write $out: $!\n";
my $n=1;
my ($name,$seq,$plus,$qual,$s,$q);
while (my $line=<IN>) {
#@MN00129:3:000H22KYJ:1:11101:14202:1055 1:N:0:1
#AACTCCTACGGAAGGCAGCAGTGATAAACCTTTAGCAATAAACCAAAGTTTAACTAAGCCATACTAACCCCAGGGTTGGTCAATTTCGTGCCAGCCACCGCGGTCACACGATTAACCCAAGTCAATAGAAACCGGCATAAAGAGTGTTTTAGATCAATTCCCCTCAATAAAGCTAAAATTCACGTGAGTTGTAAAAAACTCCAGTTGATACAAAATAAACTACGAAAGTGGCTTTAATGCATCT
#+
#AAAFFFFCGC?GE?2AEFGHHFHGHHGHHHHHHHHHHHHHGHHHEHEHHHHFHHHGBFHGHHGHHGHHHHGGGGF2?@EEHHGHHHHHHEGGHEFGHHHEEGGA/EFFH?EGHGGHHHGEHHHHFHFDFHHGA<@CGDFHBFGGFHFGFFGCGGGBGHHHHHHGG.GHHHBDHHHGFHGHHHGFGEEGHGFFF0C:0BGGEFFGGFGBCBFF09.BF0;BF0/9E.AA/9/A.FBB99B//;BF
	chomp $line;
	if ($n%4==1) {
		$name=$line;
		if ($name!~/^@/) {
			print "error: line $n\n";
			exit;
		}
		$name=~s/^@//;
		my @temp=split/\s/,$name;
		my $flag=join ";",@temp;
		print OUT ">$flag\n";
	}elsif ($n%4==2) {
		$seq=$line;
		print OUT "$seq\n";
	}elsif ($n%4==3) {
		$plus=$line;
		if ($plus!~/^\+/) {
			print "error: line $n\n";
			exit;
		}
	}elsif ($n%4==0) {
		$qual=$line;
		$s=length $seq;
		$q=length $qual;
		if ($s!=$q) {
			print "error: line $n\n";
			print "read name: $name\n";
			print "The length of qualities is not equal to that of bases\n";
			exit;
		}
	}
	$n++;
}
close IN;


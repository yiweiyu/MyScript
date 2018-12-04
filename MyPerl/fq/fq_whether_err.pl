#!/usr/bin/perl

#*********************************************************************************
# FileName: fq_whether_err.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-16
# Description: This code is to get the line number of the first error line in the
#              input fq file.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

if (@ARGV!=1) {
	die "	Usage: perl $0 <input>\n";
}
my $in=shift;
open (IN, "$in") or die "Can not open $in: $!\n";
my $n=1;
my ($name,$seq,$plus,$qual,$s,$q);
while (my $line=<IN>) {
#@M04030:17:000000000-AU86A:1:1101:12696:1847_1
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
	}elsif ($n%4==2) {
		$seq=$line;
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


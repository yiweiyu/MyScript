#!/usr/bin/perl

#*********************************************************************************
# FileName: fq_whether_eq.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-16
# Description: This code is to get the unique fq record of the input fq files.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

if (@ARGV!=3) {
	die "	Usage: perl $0 <input1> <input2> <output>\n";
}
my $in_1=shift;
my $in_2=shift;
my $out=shift;
open (IN1, "$in_1") or die "Can not open $in_1: $!\n";
my (%hash,$name,$seq,$plus,$qual,$s,$q);
my $n=1;
while (my $line=<IN1>) {
#@M04030:17:000000000-AU86A:1:1101:12696:1847_1
#AACTCCTACGGAAGGCAGCAGTGATAAACCTTTAGCAATAAACCAAAGTTTAACTAAGCCATACTAACCCCAGGGTTGGTCAATTTCGTGCCAGCCACCGCGGTCACACGATTAACCCAAGTCAATAGAAACCGGCATAAAGAGTGTTTTAGATCAATTCCCCTCAATAAAGCTAAAATTCACGTGAGTTGTAAAAAACTCCAGTTGATACAAAATAAACTACGAAAGTGGCTTTAATGCATCT
#+
#AAAFFFFCGC?GE?2AEFGHHFHGHHGHHHHHHHHHHHHHGHHHEHEHHHHFHHHGBFHGHHGHHGHHHHGGGGF2?@EEHHGHHHHHHEGGHEFGHHHEEGGA/EFFH?EGHGGHHHGEHHHHFHFDFHHGA<@CGDFHBFGGFHFGFFGCGGGBGHHHHHHGG.GHHHBDHHHGFHGHHHGFGEEGHGFFF0C:0BGGEFFGGFGBCBFF09.BF0;BF0/9E.AA/9/A.FBB99B//;BF
	chomp $line;
	if ($n%4==1) {
		if ($line!~/^@/) {
			print "error: line $n in $in_1\n";
			exit;
		}
		$name=$line;
		$hash{$name}[0]=$line;
	}elsif ($n%4==2) {
		$hash{$name}[1]=$line;
	}elsif ($n%4==3) {
		if ($line!~/^\+/) {
			print "error: line $n in $in_1\n";
			exit;
		}
		$hash{$name}[2]=$line;
	}elsif ($n%4==0) {
		$hash{$name}[3]=$line;
		$s=length $hash{$name}[1];
		$q=length $hash{$name}[3];
		if ($s!=$q) {
			print "error: line $n in $in_1\n";
			print "read name: $name\n";
			print "The length of qualities is not equal to that of bases\n";
			exit;
		}
	}
	$n++;
}
close IN1;

open (IN2, "$in_2") or die "Can not open $in_2: $!\n";
open (OUT2, ">$out.2") or die "Can not write $out.2: $!\n";
$n=0;
while (my $line=<IN2>) {
	$n++;
	chomp $line;
	$name=$line;
	if ($name!~/^@/) {
		print "error: line $n in $in_2\n";
		exit;
	}
	$seq=<IN2>;
	$n++;
	chomp $seq;
	$plus=<IN2>;
	$n++;
	chomp $plus;
	if ($plus!~/^\+/) {
		print "error: line $n in $in_2\n";
		exit;
	}
	$qual=<IN2>;
	chomp $qual;
	$n++;
	$s=length $seq;
	$q=length $qual;
	if ($s!=$q) {
		print "error: line $n in $in_2\n";
		print "read name: $name\n";
		print "The length of qualities is not equal to that of bases\n";
		exit;
	}
	if (exists $hash{$name}) {
		if ($hash{$name}[1] eq $seq and $hash{$name}[3] eq $qual) {
			delete $hash{$name};
		}else {
			print OUT2 "$name\n$seq\n$plus\n$qual\n";
		}
	}else {
		print OUT2 "$name\n$seq\n$plus\n$qual\n";
	}
}
close IN2;
close OUT2;

open (OUT1, ">$out.1") or die "Can not write $out.1: $!\n";
foreach my $key (keys %hash) {
	print OUT1 "$hash{$key}[0]\n$hash{$key}[1]\n$hash{$key}[2]\n$hash{$key}[3]\n";
}
close OUT1;

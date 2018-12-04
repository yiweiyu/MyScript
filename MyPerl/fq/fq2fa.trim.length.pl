#!/usr/bin/perl

#*********************************************************************************
# FileName: fq2fa.trim.length.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-8-17
# Description: This code is to convert fastq file to fasta file.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;
use Cwd 'abs_path';

use FindBin qw($Bin);
use lib "$Bin/../pm";
use openfile;

if (@ARGV!=4) {
	die "	Usage: perl $0 <input> <output> <trim> <size>\n";
}
my $in=shift;
my $out=shift;
my $trim=shift;
my $size=shift;

#$in=abs_path();
#$out=abs_path();
my $content=openfile($in);
#open (IN, "$in") or die "Can not open $in: $!\n";
open (OUT, ">$out") or die "Can not write $out: $!\n";
my $n=1;
my ($name,$seq,$flag);
while (my $line=<$content>) {
#@MN00129:3:000H22KYJ:1:11101:14202:1055 1:N:0:1
#AACTCCTACGGAAGGCAGCAGTGATAAACCTTTAGCAATAAACCAAAGTTTAACTAAGCCATACTAACCCCAGGGTTGGTCAATTTCGTGCCAGCCACCGCGGTCACACGATTAACCCAAGTCAATAGAAACCGGCATAAAGAGTGTTTTAGATCAATTCCCCTCAATAAAGCTAAAATTCACGTGAGTTGTAAAAAACTCCAGTTGATACAAAATAAACTACGAAAGTGGCTTTAATGCATCT
#+
#AAAFFFFCGC?GE?2AEFGHHFHGHHGHHHHHHHHHHHHHGHHHEHEHHHHFHHHGBFHGHHGHHGHHHHGGGGF2?@EEHHGHHHHHHEGGHEFGHHHEEGGA/EFFH?EGHGGHHHGEHHHHFHFDFHHGA<@CGDFHBFGGFHFGFFGCGGGBGHHHHHHGG.GHHHBDHHHGFHGHHHGFGEEGHGFFF0C:0BGGEFFGGFGBCBFF09.BF0;BF0/9E.AA/9/A.FBB99B//;BF
	chomp $line;
	if ($n%4==1) {
		$name=$line;
		$name=~s/^@//;
		my @temp=split/\s/,$name;
		$flag=join ";",@temp;
	}elsif ($n%4==2) {
		my $len=length $line;
		if ($len<($trim+$size)) {
			next;
		}
		if ($line=~/[^ATGCatgc]/) {
			next;
		}
		$seq=substr($line,$trim);
		#$seq=$line;
		#$seq=~s/^(.){$trim}//;
		$len=length $seq;
		if ($len>$size) {
			print OUT ">$flag\n$seq\n";
		}
	}
	$n++;
}
close $content;
close OUT;


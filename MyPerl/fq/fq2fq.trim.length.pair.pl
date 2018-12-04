#!/usr/bin/perl

#*********************************************************************************
# FileName: fq2fq.trim.length.pair.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-8-18
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

if (@ARGV!=5) {
	die "	Usage: perl $0 <input1> <input2> <outprefix> <trim> <size>\n";
}
my $in1=shift;
my $in2=shift;
my $out=shift;
my $trim=shift;
my $size=shift;

my $content=openfile($in1);
my $content2=openfile($in2);
open (OUT1, ">$out.R1.fq") or die "Can not write $out.R1.fq: $!\n";
open (OUT2, ">$out.R2.fq") or die "Can not write $out.R2.fq: $!\n";
my $n=1;
my ($name,$seq,$flag,$plus,$qual,$name2,$seq2,$flag2,$plus2,$qual2,$want);
while (my $line=<$content>) {
#@MN00129:3:000H22KYJ:1:11101:14202:1055 1:N:0:1
#AACTCCTACGGAAGGCAGCAGTGATAAACCTTTAGCAATAAACCAAAGTTTAACTAAGCCATACTAACCCCAGGGTTGGTCAATTTCGTGCCAGCCACCGCGGTCACACGATTAACCCAAGTCAATAGAAACCGGCATAAAGAGTGTTTTAGATCAATTCCCCTCAATAAAGCTAAAATTCACGTGAGTTGTAAAAAACTCCAGTTGATACAAAATAAACTACGAAAGTGGCTTTAATGCATCT
#+
#AAAFFFFCGC?GE?2AEFGHHFHGHHGHHHHHHHHHHHHHGHHHEHEHHHHFHHHGBFHGHHGHHGHHHHGGGGF2?@EEHHGHHHHHHEGGHEFGHHHEEGGA/EFFH?EGHGGHHHGEHHHHFHFDFHHGA<@CGDFHBFGGFHFGFFGCGGGBGHHHHHHGG.GHHHBDHHHGFHGHHHGFGEEGHGFFF0C:0BGGEFFGGFGBCBFF09.BF0;BF0/9E.AA/9/A.FBB99B//;BF
	chomp $line;
	my $line2=<$content2>;
	chomp $line2;
	if ($n%4==1) {
		$name=$line;
		$name2=$line2;
		my @temp=split/\s/,$name;
		my @temp2=split/\s/,$name2;
		$flag=join ";",@temp;
		$flag2=join ";",@temp2;
	}elsif ($n%4==2) {
		my $len=length $line;
		my $len2=length $line2;
		if ($len<($trim+$size) or $len2<($trim+$size)) {
			next;
		}
		if ($line=~/[^ATGCatgc]/ or $line2=~/[^ATGCatgc]/) {
			next;
		}
		$seq=substr($line,$trim);
		$seq2=substr($line2,$trim);
		#$seq=$line;
		#$seq=~s/^(.){$trim}//;
		$len=length $seq;
		$len2=length $seq2;
		$want=0;
		if ($len<$size or $len2<$size) {
			next;
		}else {
			$want=1;
		}
	}elsif ($n%4==3) {
		$plus=$line;
		$plus2=$line2;
	}elsif ($n%4==0) {
		if ($want==0) {
			next;
		}
		$qual=substr($line,$trim);
		$qual2=substr($line2,$trim);
		print OUT1 "$flag\n$seq\n$plus\n$qual\n";
		print OUT2 "$flag2\n$seq2\n$plus2\n$qual2\n";
	}
	$n++;
}
close $content;
close $content2;
close OUT1;
close OUT2;


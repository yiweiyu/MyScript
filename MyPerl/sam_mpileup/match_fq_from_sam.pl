#!/usr/bin/perl

#*********************************************************************************
# FileName: match_fq_from_sam.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-5-26
# Description: This code is to get matched reads from input sam file ,then print 
#              them to result fastq files(forward fq file, reverse fq file and 
#              single fq file).
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 <input_sam> <input_fq> <output_prefix>
USAGE

if (@ARGV!=3) {
	die $usage;
}
my $sam=$ARGV[0];
my $fq=$ARGV[1];
my $out_prefix=$ARGV[2];

my (%hash);
open IN,$sam || die "Can't open $sam: $!\n";
while (my $line=<IN>) {
	chomp $line;
	if ($line=~/^$/) {
		next;
	}
	#@HD     VN:1.0  SO:unsorted
	#@SQ     SN:chr19_42788849_42799128_CIC  LN:10279
	if ($line=~/^\@[A-Z]{2}/) {
		next;
	}
	#E00509:81:HF7YCALXX:8:1101:20750:1995   4       *       0       0       *       *       0       0       CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC  IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII  YT:Z:UU
	#E00509:81:HF7YCALXX:8:1101:19076:3454   0       chrX_76763743_77041578_ATRX     174776  42      35M     *       0       0       TCCTGCTCACCTCTTTGAGGATTGCTAGCATTTCA     IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII     AS:i:0  XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:35 YT:Z:UU
	my @lines=(split/\s+/,$line);
	if ($lines[2] ne "*") {
		my $name=$lines[0];
		my $flag=$lines[1];
		my $binary=sprintf("%b", $flag);
		my $newbi=sprintf("%012d", $binary);
		my @know=split //,$newbi;
		my $one_two;
		if ($know[-7]==1) {
			$one_two=1;
		} elsif ($know[-8]==1) {
			$one_two=2;
		}
		my $newname=$name."_$one_two";
		$hash{$newname}=1;
	}
}
close IN;

open OUT1,">$out_prefix.1.fq" || die "Can't write $out_prefix.1.fq: $!\n";
open OUT2,">$out_prefix.2.fq" || die "Can't write $out_prefix.2.fq: $!\n";
open IN, $fq || die "Can't open $fq: $!\n";
while (my $line=<IN>) {
	#@E00509:81:HF7YCALXX:8:1101:5365:9027 1:N:0:TCAAGA
	#GGCCATAGTCCTGTTTGGCCAGACCTGGATTCAGATCGGAAGAGCGGTTCAGCAGGAATGCCGAGACCGTGCTGGGTATCTCGTATGCCGTCTTCTGCTTGAAAAAA
	#+
	#AAFFFJJJJJJJJJFJJJJJJAJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ<FJJJJJJJJJJAAJAJJFFJAJJJJJ
	chomp $line;
	if ($line=~/^\@/) {
		my @temp=(split/\s+/,$line);
		my $readname=$temp[0];
		my $mate=(split/:/,$temp[1])[0];
		$readname=~s/^\@//;
		my $pairname=$readname."_$mate";
		my ($seq,$plus,$quality);
		if (exists $hash{$pairname}) {
			if ($mate==1) {
				$seq=<IN>;
				chomp $seq;
				$plus=<IN>;
				chomp $plus;
				$quality=<IN>;
				chomp $quality;
				print OUT1 "$line\n$seq\n$plus\n$quality\n";
			}elsif ($mate==2) {
				$seq=<IN>;
				chomp $seq;
				$plus=<IN>;
				chomp $plus;
				$quality=<IN>;
				chomp $quality;
				print OUT2 "$line\n$seq\n$plus\n$quality\n";
			}
		}
	}
}
close IN;
close OUT1;
close OUT2;

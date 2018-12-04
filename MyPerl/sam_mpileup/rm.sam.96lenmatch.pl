#!/usr/bin/perl

#*********************************************************************************
# FileName: rm.sam.96lenmatch.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-7-7
# Description: This code is get seqs whose lenmatch less than 96.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;
use Getopt::Long;

my $usage=<<USAGE;
	Usage:perl $0  <-i insam> <-o outfa>
USAGE

my ($in,$out);
GetOptions(
	"i:s"=>\$in,
	"o:s"=>\$out,
);
if (defined($in)==0 or defined($out)==0) {
	die $usage;
}


open IN,$in || die "Can't open $in: $!\n";
open OUT,">$out" || die "Can't write $out: $!\n";
my (%hash1,%hash2,%com1,%com2,%cutoff1,%cutoff2,%all);
while (my $line=<IN>) {
	chomp $line;
	if ($line=~/^$/) {
		next;
	}
#	@HD     VN:1.4  SO:unsorted
#	@RG     ID:FASTQ        PL:Illumina     PU:pu   LB:lb   SM:sm
	if ($line=~/^\@(\w+)/) {
		next;
	}
#	M04030:17:000000000-AU86A:1:1106:10889:9523_1   77      *       0       0       *       =       0       0       AGCTACAGGCTTAACACATGCAAGTCGAGGGGTAGCAGGACCTAGCAATAGGTTGCTGACGACCGGCGCACGGGTGAGTAACACGTATCCAACCTGCCTCATACTCTGGGATAGCCTTTCGAAAGAAAGATTAATACTGGATGGCATAATTGAACCGCATGGTTTGATTATTAAAGAATTTCGGTATGAGATGGGGATGCGTTCCATTAGATAG  GAHGHHHHFFHHHHEFHHHFHGHHHHGFFGGGFGGHHHGFHHHHHHHHHHGHDFGHHHHHGGGGGEGGGGGGGGDGHHHHHHHHGHHHHHGHHDHFHHHHHHDGHHGFHHHHHHHHHHHFGGHDGGHHBGHHBBGHHHHFCGHGGGGGFFFFGGGGGGCGGF;FFDFFBFGGGFFFFFFFFF.BEFFFFFBFFFFFFFFFFDDFBFFFFB/BFF  PG:Z:SNAP       NM:i:-1 RG:Z:FASTQ      PL:Z:Illumina   PU:Z:pu LB:Z:lb SM:Z:sm
#	M04030:17:000000000-AU86A:1:1110:26640:23518_1  355     gi|219878436|ref|NR_025575.1|_Vibrio_fortis_strain_CAIM_629_16S_ribosomal_RNA,_partial_sequence 351     0       108M1D4M1I84M   =       559     407     TGCACAATGGGCGCAAGCCTGATGCAGCCATGCCGCGTGTATGAAGAAGGCCTTCGGGTTGTAAAGTACTTTCAGTTGTGAGGAAGGGGGTATCGTTAATAGCGGTATTCTTTGACGTTAGCGACAGAAGAAGCACCGGCTAACTCCGTGCCAGCAGCCGCGGTAATACGGAGGGTGCGAGCGTTAATCGGAATTAC   HHGHHHHHGFHGGGGGGHGGHHHHHHGHEHFHHHGGG/EEGHHHHHHHHGGGHHFHGGGGEEHHHHGGHHHHHHHHHHFFHGGGHHGGGG@DHHGHHHGHGHFDGGDFHHHHHHHHGGGHGHGGGGGHHHGEFGFFGCFGGGGGGGGG;EDE0BEFFFFFFFF.AEFFFFFD.@AAEA>.@;>;DDEFFEFAE?BFF   PG:Z:SNAP       NM:i:8  RG:Z:FASTQ      PL:Z:Illumina   PU:Z:pu LB:Z:lb SM:Z:sm
	my @lines=split /\t/,$line;
	if ($lines[2] eq "*") {
		print OUT ">$lines[0]\n$lines[9]\n";
		next;
	}
	if ($lines[5]=~/^\*$/) {
		print OUT ">$lines[0]\n$lines[9]\n";
		next;
	}
	my @line5=split /[A-Z]/,$lines[5];
	my $all=length $lines[9];
	my $len=0;
	foreach my $item (@line5) {
		$len+=$item;
	}
	my $cut=$len/$all;
	unless ($cut>=0.96) {
		print OUT ">$lines[0]\n$lines[9]\n";
		next;
	}
}
close IN;
close OUT;


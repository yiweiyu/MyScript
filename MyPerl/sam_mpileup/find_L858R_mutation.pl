#!/usr/bin/perl -w

#*****************************************************************************
# FileName: find_L858R_mutation.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-12-13
# Description: This code is to find reads containing L858R mutation.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 <sam> <out_prefix>
USAGE
if (@ARGV!=2) {
	die $usage;
}
my $sam=shift;
my $out_prefix=shift;

open SAM, $sam or die "Can't open '$sam': $!\n";
open OUT,">","$out_prefix.L858R_reads.name"
	or die "Can't open '$out_prefix.L858R_reads.name': $!\n";
my (%mark,%count);
while (my $line=<SAM>) {
	chomp $line;
	if ($line=~/^@/ or $line=~/^\s+$/) {
		next;
	}
	#MN00129:33:000H2C3FY:1:11103:24824:1480 89      chr7_55259351_55259784  92      0       20M2I107M1D4M   =       92      0       GAGTGCAGCGGATTGGAGTCCTCAGGAACGTACTGGTGTAAACACCGCAGCATGTCAAGATCACAGAGTTTGGGCGGGCCAAACTGCTGGGTGCGGAAGAGAAAGAATACCATGCAGAAGGAGGCTAAGAAGG   FA/FF==//FF//FF/FFFF/A/A==FF=F/FFF/FFF/F/AFFAFAFAF/FFFFFF/FF/6FF/FF/FF//AFF//AFFF/FFF///FFFAA=AFF/FAA=AFFFFAFFFA/AFA=AFFFFAFA//FFF/AA   AS:i:-76        XN:i:0  XM:i:14 XO:i:2  XG:i:3  NM:i:17 MD:Z:1T1C0A1C3A0C0C3C0A0G17A28T7T49A3^T4        YT:Z:UP
	#MN00129:33:000H2C3FY:1:11103:24824:1480 133     chr7_55259351_55259784  92      0       *       =       92      0       GAGTGCAGCGGCTTCCAGTCCTCAGGAACGTACTGGTGAAAACACCGCCGCATGTCAAGATCACCGATTTTGGGCGGGCCAAACTGCTGGGTGCGGATGAGAAAGAAGACCATGCAGCAGGAGGCAAAGAAGGCAAACCGCAATACTGTG  FAFFFFFFFFAFF/F/////////A=//AAFA=AFAAA//F/F/FFFF/F//AA/F/AF/FA///F/=FFFAFFF/FFAF///A/F//FFF/FFFFA/FFAF//F////FA/FFF/A/AF=/=//A/////FFF/A=/////A//A/F//  YT:Z:UP
	#MN00129:33:000H2C3FY:1:11101:14979:5113 99      chr7_55259351_55259784  3       24      150M    =       33      169     GATGCAGAGCTTCTTCCCATGATGATCTGTCCCTCACAGCAGGGTCTTCTCTGTTTCAGGGCATGAACTACTTGGAGGACCGTCGCTTGGTGCACCGCGACCTGGCAGCCAGGAACGTACTGGTGAAAACACCGCAGCATGTCAAGATCA  AAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFFFFFFFFFFFFFFFFFFFFFFFAFFFAAA/AF  AS:i:0  XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:150        YS:i:-65        YT:Z:CP
	#MN00129:33:000H2C3FY:1:11101:14979:5113 147     chr7_55259351_55259784  33      24      128M4I4M8I7M    =       3       -169    CCCTCACAGCAGGGTCTTCTCTGTTTCAGGGCATGAACTACTTGGAGGACCGTCGCTTGGTGCACCGCGACCTGGCAGCCAGGAACGTACTGGTGAAAACACCGCAGCATGTCAAGATCACAGATTTTATTAGTTCTATGCCCATGGCTAT FFFFFFFFFF/FFF/FFAFFFAAF/AF=FFFFFFF=FAFFFFFFFFFFFFFA/FFFFF/F=FAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF/FAF66FFFFFFFFFFFFFFA AS:i:-65        XN:i:0  XM:i:4  XO:i:2  XG:i:12 NM:i:16 MD:Z:129G0G5C1A0        YS:i:0  YT:Z:CP
	my ($name,$ref,$start,$cigar,$seq,$qual)=(split /\t/ , $line)[0,2,3,5,9,10];
	if ($ref ne "chr7_55259351_55259784" or $cigar eq "*") {
		next;
	}
	my @info_ref=split (/[MDN=X]/,$cigar);
	my $len=0;
	foreach my $i (@info_ref) {
		my $num=(split /[ISHP]/,$i)[-1];
		$len+=$num;
	}
	my $stop=$start+$len-1;
	if (165>=$start and 165<=$stop) {
		my $site=165-$start;
		my @bp=split//,$seq;
		my @quality=split//,$qual;
		my @info_num=split (/[MISDN=X]/,$cigar);
		my $cigar_cp=$cigar;
		$cigar_cp=~s/[0-9]//g;
		my @info_cg=split (//,$cigar_cp);
		my $len_temp=0;
		if (@info_num!=@info_cg) {
			print "error: $name\t$cigar\n";
		}
		foreach my $i (0..$#info_cg) {
			if ($info_cg[$i]=~/[M=X]/) {
				$len_temp+=$info_num[$i];
				if ($len_temp>$site) {
					last;
				}
			}elsif ($info_cg[$i]=~/[IS]/) {
				$site+=$info_num[$i];
				$len_temp+=$info_num[$i];
				if ($len_temp>$site) {
					last;
				}
			}elsif ($info_cg[$i]=~/[DN]/) {
				$site-=$info_num[$i];
				if ($len_temp>$site) {
					last;
				}
			}
		}
		if (!exists $mark{$name} and $bp[$site] eq "G") {
		#if ($bp[$site] eq "G") {
			$mark{$name}=1;
			print "$name\t$site\t$cigar\t$quality[$site]\n";
			print OUT "$name\n";
		}
	}
}
close SAM;
close OUT;


#!/usr/bin/perl -w

#*****************************************************************************
# FileName: nc_00.count.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-12-27
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 <statistic> <bed> <sam> <detail> <out_prefix>
USAGE
if (@ARGV!=5) {
	die $usage;
}
my $statistic=shift;
my $bed=shift;
my $sam=shift;
my $detail=shift;
my $out_prefix=shift;

my $all_reads=`head -1 $statistic`;
chomp $all_reads;

system "date";
my %bedsite;
open BED, $bed or die "Can't open '$bed': $!\n";
while (my $line=<BED>) {
	#chr1    2488098 2488177
	chomp $line;
	my ($chr,$start,$stop)=(split/\s+/,$line)[0,1,2];
	foreach my $i ($start..$stop) {
		$bedsite{$chr}{$i}=1;
	}
}
close BED;

system "date";
open SAM, $sam or die "Can't open '$sam': $!\n";
my ($all_map,$bed_map)=(0)x2;
while (my $line=<SAM>) {
	chomp $line;
	if ($line=~/^@/ or $line=~/^\s+$/) {
		next;
	}
	#NCCL:000000e0-a25b-4dab 99      chr12   12028062        42      100M    =       12028128        166     AGTAGGTGGTTGACAGTTTAAATACAAATCACAAATGACATCTTTTTAAATATAACAAGTAGCTTATTTTTAAAGGTGTCACTTACTTTGCAAAGTATAA    ccccchhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhghhhhhhhhhhhhhhhhhggghhhhhhhhhhhhhhhhhghhhhhhhhhhhhhhgggghggg    AS:i:-6 XN:i:0  XM:i:1  XO:i:0  XG:i:0  NM:i:1  MD:Z:95G4       YS:i:-6 YT:Z:CP
	#NCCL:000000e0-a25b-4dab 147     chr12   12028128        42      100M    =       12028062        -166    TTTTTAAAGGTGTCACTTACTTTGCAAAGTATAAGGAGAACTGTTATTAAGAATTTACCAGGTTGGAATGGCTAGTGTTTATGGGAGAGAGTTTAGCACA    ghhhhhhhhhhhhhhhhghhhhhhhhhhhhhhhhhhhhggg^hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhgccccc    AS:i:-6 XN:i:0  XM:i:1  XO:i:0  XG:i:0  NM:i:1  MD:Z:29G70      YS:i:-6 YT:Z:CP
	my ($name,$ref,$start,$cigar)=(split /\t/ , $line)[0,2,3,5];
	if ($cigar eq "*") {
		next;
	}
	my @info_ref=split (/[MDN=X]/,$cigar);
	my $len=0;
	foreach my $i (@info_ref) {
		my $num=(split /[IS]/,$i)[-1];
		$len+=$num;
	}
	my $stop=$start+$len-1;
	my $half=($start+$stop)/2;
	my $half_int=int $half;
	if (exists $bedsite{$ref}{$start} and exists $bedsite{$ref}{$half_int} and exists $bedsite{$ref}{$stop}) {
		$all_map++;
		$bed_map++;
	}else {
		$all_map++;
	}
}
close SAM;
system "date";

my ($all_dep,$all_bedsite)=(0)x2;
open DETAIL, $detail or die "Can't open '$detail': $!\n";
while (my $line=<DETAIL>) {
	#des     pos     ref     dep     freStat A       G       C       T       total   A_entropy       G_entropy       C_entropy       T_entropy
	#chrMT   11      C       2       A:0;G:0;C:2;T:0;tot:2   0       0       2       0       2       0       0       1       0       0
	chomp $line;
	if ($line=~/^des/) {
		next;
	}
	my ($ref,$pos,$dep)=(split /\t/, $line)[0,1,3];
	if (exists $bedsite{$ref}{$pos}) {
		$all_dep+=$dep;
		$all_bedsite++;
	}
}
close DETAIL;
my $aver_cover=sprintf "%g",$all_dep/$all_bedsite;

my $map_all_ratio=sprintf "%g",$all_map/$all_reads;
my $map_bed_ratio=sprintf "%g",$bed_map/$all_reads;
open OUT,">","$out_prefix\_ct.xls"
	or die "Can't open '$out_prefix\_ct.xls': $!\n";
print OUT "$all_reads\t$map_all_ratio\t$map_bed_ratio\t$bed_map\t$aver_cover\n";
close OUT;
system "date";


#!/usr/bin/perl

#*****************************************************************************
# FileName: statistic.bsi.allout.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-19
# Description: This code is to get the information of 20species, otherspecies 
#              and statistic in BSI result, get the number of reads in V1-V2,
##              V3-V4, V5-V6 and V7-V8 after removing redundant reads.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#Usage:
#    perl $0  <result_dir> <name_list> <output>
#*****************************************************************************

use strict;
use warnings;

if (@ARGV!=3) {
	die "Usage: perl $0 <result_dir> <name_list> <output>\n";
}
my $resultdir="$ARGV[0]";
my $list="$ARGV[1]";
my $out="$ARGV[2]";

open LIS,"$list" or die "Can't open $list: $!\n";
my ($line,%result2sample);
while ($line=<LIS>) {
	#BL201701001130  /share/data/file/100/20170331/17033106175654.tar.gz
	chomp $line;
	my @temp=split /\//, $line;
	my $sample=$temp[0];
	$sample=~s/\s+//;
	my $tar_name=$temp[-1];
	$tar_name=~s/.tar.gz//;
	$result2sample{$tar_name}=$sample;
}

open OUT,">$out" or die "Can't write $out: $!\n";
print OUT "Sample\tSize\tPath\tTotal_R\tQC\tGC\tHuman_R\t16S_R\t";
print OUT "Positive_20\tOthers_species\tV1-V2\tV3-V4\tV5-V6\tV7-V8\n";
my @array = glob("$resultdir/1*");
foreach my $path (@array) {
	my (@val,$element);
	my $result=(split /\//, $path)[-1];
	my $data_dir="$path/$result2sample{$result}";
	my $size_info= `du -sh $data_dir`;
	my $size=(split /\s+/,$size_info)[0];
	print OUT "$result2sample{$result}\t$size\t$path\t";

	my $statistic="$path/result/statistic.xls";
	my $positive="$path/result/20.species";
	my $others="$path/result/other.species";
	my $region_4="$path/result/4region.repeat";

	open STAT,"$statistic" or die "Can't open $statistic: $!\n";
	while ($line=<STAT>) {
		#7566
		#34.2
		#57%
		#4703
		#156
		chomp($line);
		print OUT "$line\t";
	}
	close STAT;

	open POSI,"$positive" or die "Can't open $positive: $!\n";
	my $positive_20="";
	while ($line=<POSI>) {
		#Klebsiella pneumoniae   32,57.7142857142857     203,89.6774193548387    41,79.7153024911032     5,72.4919093851133      2.28(26)                V3-V4 >M04030:14:000000000-AKK1U:1:1104:26068:13332_1 TGCACAATGGGCGCAAGCCTGATGCAGCCATGCCGCGTGTGTGAAGAAGGCCTTCGGGTTGTAAAGCACTTTCAGCGGGGAGGAAGGCGATAAGGTTAATAACCTCATCGATTGACGTTACCCGCAGAAGAAGCACCGGCTAACTCCGTGCCAGCAGCCGCGGTAATACGGAGGGTGCAAGCGTTAATCGGAATTAC     V3-V4 >M04030:14:000000000-AKK1U:1:1104:26068:13332_2 CCACGCTTTCGCACCTGAGCGTCAGTCTTTGTCCAGGGGGCCGCCTTCGCCACCGGTATTCCTCCAGATCTCTACGCATTTCACCGCTACACCTGGAATTCTACCCCCCTCTACAAGACTCTAGCCTGCCAGTTTCGAATGCAGTTCCCAGGTTGAGCCCGGGGATTTCACATCCGACT       V5-V6 >M04030:14:000000000-AKK1U:1:1110:14232:4070_2 CCACGCTTTCGCACCTGAGCGTCAGTCTTTGTCCAGGGGGCCGCCTTCGCCACCGGTATTCCTCCAGATCTCTACGCATTTCACCGCTACACCTGGAATTCTACCCCCCTCTACAAGACTCTAGCCTGCCAGTTTCGAATGCAGTTCCCAGGTTGAGCCCGGGGATTTCACATCCGACTTGACAGACCGCCTGCGTGCG    V7-V8 >M04030:14:000000000-AKK1U:1:1116:14127:8627_2 CCACGCTTTCGCACCTGAGCGTCAGTCTTTGTCCAGGGGGCCGCCTTCGCCACCGGTATTCCTCCAGATCTCTACGCATTTCACCGCTACACCTGGAATTCTACCCCCCTCTACAAGACTCTAGCCTGCCAGTTTCGAATGCAGTTCCCAGGTTGAGCCCGGGGATTTCACATCCG
		chomp($line);
		@val=split/\t/,$line;
		$positive_20.="$val[0] $val[5]; ";
	}
	if ($positive_20 eq "") {
		$positive_20="_";
	}
	print OUT "$positive_20\t";
	close POSI;

	open OTHE,"$others" or die "Can't open $others: $!\n";
	my $others_species="";
	while ($line=<OTHE>) {
		#Aeromonas hydrophila    0,0     64,85.5913978494624     0,0     4,83.8187702265372      5.98(68)                V3-V4 >M04030:14:000000000-AKK1U:1:2104:11722:24913_2 CCACGCTTTCGCACCTGAGCGTCAGTCTTTGTCCAGGGGGCCGCCTTCGCCACCGGTATTCCTCCAGATCTCTACGCATTTCACCGCTACACCTGGAATTCTACCCCCCTCTACAAGACTCTAGCTGGACAGTTTTAAATGCAATTCCCAGGTTGAGCCCGGGGCTTTCACATCTAACTTATCCAACCGCCTGCGTGCG   V3-V4 >M04030:14:000000000-AKK1U:1:1111:10696:17493_1 TGCACAATGGGGGAAACCCTGATGCAGCCATGCCGCGTGTGTGAAGAAGGCCTTCGGGTTGTAAAGCACTTTCAGCGAGGAGGAAAGGTTGGCGCCTAATACGTGTCAACTGTGACGTTACTCGCAGAAGAAGCACCGGCTAACTCCGTGCCAGCAGCCGCGGTAATACGGAGGGTGCAAGCGTTAATCGGAATTAC     V3-V4 >M04030:14:000000000-AKK1U:1:1105:7038:10712_2 CCACGCTTTCGCACCTGAGCGTCAGTCTTTGTCCAGGGGGCCGCCTTCGCCACCGGTATTCCTCCAGATCTCTACGCATTTCACCGCTACACCTGGAATTCTACCCCCCTCTACAAGACTCTAGCTGGACAGTTTTAAATGCAATTCCCAGGTTGAGCCCGGGGCTTTCACATCTAACTTATCCAACCGCCTGCGT       V3-V4 >M04030:14:000000000-AKK1U:1:2117:25369:7925_1 TGCACAATGGGGGAAACCCTGATGCAGCCATGCCGCGTGTGTGAAGAAGGCCTTCGGGTTGTAAAGCACTTTCAGCGAGGAGGAAAGGTTGGTAGCGAATAACTGCCAGCTGTGACGTTACTCGCAGAAGAAGCACCGGCTAACTCCGTGCCAGCAGCCGCGGTAATACGGAGGGTGCAAGCGTTAATCGGAATTAC
		chomp($line);
		@val=split/\t/,$line;
		$others_species.="$val[0] $val[5]; ";
	}
	if ($others_species eq "") {
		$others_species="_";
	}
	print OUT "$others_species\t";
	close OTHE;

	open REGI,"$region_4" or die "Can't open $region_4: $!\n";
	my $string1="";
	my $string2="";
	my $string3="";
	my $string4="";
	while ($line=<REGI>) {
		##strain_id      #pair1_num      #pair2_num      #pair3_num      #pair4_num      #unique_num     #pair1_name     #pair2_name     #pair3_name     #pair4_name     #unique_name    #strain_merged  #simmilar_strain
		#100581  4,91.4285714285714      0,0     0,0     0,0     0       M04030:14:000000000-AKK1U:1:1105:16561:6410_2,M04030:14:000000000-AKK1U:1:1112:3295:14770_1,M04030:14:000000000-AKK1U:1:1112:3295:14770_2,M04030:14:000000000-AKK1U:1:1105:16561:6410_1 0       0       0       0       Lactobacillus iners
		if ($line=~/^\#/) {
			next;
		}
		chomp($line);
		@val=split/\t/,$line;
		$string1.="$val[6],";
		$string2.="$val[7],";
		$string3.="$val[8],";
		$string4.="$val[9],";
	}
	close REGI;
	my @array1=split/,/ ,$string1;
	my @array2=split/,/ ,$string2;
	my @array3=split/,/ ,$string3;
	my @array4=split/,/ ,$string4;
	my (%v1,%v2,%v3,%v4);
	foreach $element (@array1) {
		if ($element eq "0" or $element eq "") {
			next;
		}
		$v1{$element}+=1;
	}
	foreach $element (@array2) {
		if ($element eq "0" or $element eq "") {
			next;
		}
		$v2{$element}+=1;
	}
	foreach $element (@array3) {
		if ($element eq "0" or $element eq "") {
			next;
		}
		$v3{$element}+=1;
	}
	foreach $element (@array4) {
		if ($element eq "0" or $element eq "") {
			next;
		}
		$v4{$element}+=1;
	}
	my @reads1=keys %v1;
	my $num1=@reads1;
	my @reads2=keys %v2;
	my $num2=@reads2;
	my @reads3=keys %v3;
	my $num3=@reads3;
	my @reads4=keys %v4;
	my $num4=@reads4;
	print OUT "$num1\t$num2\t$num3\t$num4\n";

}
close OUT;

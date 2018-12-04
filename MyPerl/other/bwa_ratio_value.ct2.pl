#!/usr/bin/perl -w

#*****************************************************************************
# FileName: ratio_value.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-11-17
# Description: This code is to count the sum of reads not containning fusion,
#              then calculate fusion ratio.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 
		<sam> <exact_xls> <vague_xls> 
		<plus_reads> <uniq> <plus_mt> <ratio> <out_dir>
USAGE
if (@ARGV!=8) {
	die $usage;
}
my $sam=shift;
my $exact_xls=shift;
my $vague_xls=shift;
my $plus_reads=shift;
my $uniq=shift;
my $plus_mt=shift;
my $r_value=shift;
my $out=shift;

system "date";

my %fusion;
open IN, $exact_xls or die "Can't open '$exact_xls': $!\n";
while (my $line=<IN>) {
	#site1   site2     uniq_sum      fusion_reads_num        fusion_mt_num   fusion_reads    fusion_mt_info
	#chr17:41223109|BRCA1:exon:14    chr12:20153296|null   8      8       2       GGAAGAGTTTGC:MN00129:11:000H23NKW:1:23109:4541:4336,GGAAGAGTTTGC:MN00129:11:000H23NKW:1:21109:1743:3468,TCGACAAGGATC:MN00129:11:000H23NKW:1:21110:18119:15243,GGAAGAGTTTGC:MN00129:11:000H23NKW:1:23106:11055:11029,GGAAGAGTTTGC:MN00129:11:000H23NKW:1:21108:6158:18886,GGAAGAGTTTGC:MN00129:11:000H23NKW:1:13104:8261:12974,GGAAGAGTTTGC:MN00129:11:000H23NKW:1:11102:1889:8267,GGAAGAGTTTGC:MN00129:11:000H23NKW:1:22104:7674:6365   (GGAAGAGTTTGC:7);(TCGACAAGGATC:1)
	chomp $line;
	my ($site1,$site2,$uniq_sum,$f_reads_sum)=(split/\s+/,$line)[0,1,2,3];
	if ($line=~/^site/ or $uniq_sum<$uniq or $f_reads_sum<$plus_reads) {
		next;
	}
	my $chr_pos1=(split/\|/,$site1)[0];
	my ($chr1,$pos1)=(split/:/,$chr_pos1)[0,1];
	$fusion{$chr1}{$pos1}=1;
	my $chr_pos2=(split/\|/,$site2)[0];
	my ($chr2,$pos2)=(split/:/,$chr_pos2)[0,1];
	$fusion{$chr2}{$pos2}=1;
}
close IN;

open IN, $vague_xls or die "Can't open '$vague_xls': $!\n";
while (my $line=<IN>) {
	#site1   site2     uniq_sum      fusion_reads_num        fusion_mt_num   fusion_reads    fusion_mt_info
	#chr16:68856118|CDH1:exon:12     chr7:31588875|CCDC129:intron:1    3    3       2       CCGCGAGAGAGG:MN00129:11:000H23NKW:1:12106:12399:13340_R1_R2_chr7_31588783_101M2I4M_R;right[1-85],TCTCCGAAGGCT:MN00129:11:000H23NKW:1:11108:18787:2622_R1_R2_chr7_31588783_23M_R;right[1-85],TCTCCGAAGGCT:MN00129:11:000H23NKW:1:23110:16511:9105_R1_R2_chr7_31588783_101M2I4M_R;right[1-85]     (CCGCGAGAGAGG:1);(TCTCCGAAGGCT:2)
	chomp $line;
	my ($site1,$site2,$uniq_sum,$f_reads_sum)=(split/\s+/,$line)[0,1,2,3];
	if ($line=~/^site/ or $uniq_sum<$uniq or $f_reads_sum<$plus_reads) {
		next;
	}
	my $chr_pos1=(split/\|/,$site1)[0];
	my ($chr1,$pos1)=(split/:/,$chr_pos1)[0,1];
	$fusion{$chr1}{$pos1}=1;
	my $chr_pos2=(split/\|/,$site2)[0];
	my ($chr2,$pos2)=(split/:/,$chr_pos2)[0,1];
	$fusion{$chr2}{$pos2}=1;
}
close IN;

open SAM, $sam or die "Can't open '$sam': $!\n";
my (%mark,%pre_start,%nomal_all,%nomal_num,%hash);
while (my $line=<SAM>) {
	chomp $line;
	if ($line=~/^@/ | $line=~/^\s+$/) {
		next;
	}
	#CGGCCGCGCTCG:MN00129:11:000H23NKW:1:23110:12331:20229   77      *       0       0       *       *       0       0       AGTGGATACTTATATCTTTCTCAAGTTTTAGAAAGTTTTCTATTATTGGCTGGGTGCAGTGGCTCATGCCTGTAATCCCAGCATTTTGGGAGGCCGAGGCAGGTGGATCATGAGGTCAGAAGAT    AAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6FFFFFFFFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF    YT:Z:UP
	#CGGCCGCGCTCG:MN00129:11:000H23NKW:1:23110:12331:20229   141     *       0       0       *       *       0       0       GCCTCAGCCTCCCAAGTAGATGGGACTACAGGTGCCCGCCACC     FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFAFFFFFAFF     YT:Z:UP
	#TATATCCAGCAA:MN00129:11:000H23NKW:1:23110:21779:20255   99      chr12 103     42      93M     =       145     93      TGACAATGGCTTTGACAGTGATAGCAGGATTGGTAGTGATTTTCATGATGCTGGGCGGCACTTTTCTCTACTGGCGTGGGCGCCGGATTCAGA   FFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF   AS:i:0  XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:93 YS:i:0  YT:Z:CP
	#TATATCCAGCAA:MN00129:11:000H23NKW:1:23110:21779:20255   147     chr12 145     42      51M     =       103     -93     TCATGATGCTGGGCGGCACTTTTCTCTACTGGCGTGGGCGCCGGATTCAGA     FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFFFFFFFFFFFFFFFF     AS:i:0  XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:51 YS:i:0  YT:Z:CP
	my ($name,$flag,$ref,$start,$cigar)=(split /\t/ , $line)[0,1,2,3,5];
	if (exists $mark{$name} or $cigar eq "*") {
		next;
	}
	my ($chr,$refstart)=(split /_/,$ref)[0,1];
	unless (defined $refstart) {
		$refstart=0;
	}
	if (!exists $fusion{$chr}) {
		next;
	}
	my @info_ref=split (/[MDN=X]/,$cigar);
	my $len=0;
	foreach my $i (@info_ref) {
		my $num=(split /[ISHP]/,$i)[-1];
		$len+=$num;
	}
	my $begin=$refstart+$start-1;
	my $stop=$begin+$len-1;
	foreach my $e (keys $fusion{$chr}) {
		if ($e>=$begin && $e<=$stop) {
			$mark{$name}=1;
			$nomal_all{"$chr:$e"}++;
			my $mt=(split /:/,$name)[0];
			$hash{"$chr:$e"}{$mt}=1;
			$nomal_num{"$chr:$e"}{$mt}++;
		}
	}
}
close SAM;

my %merge;
foreach my $key (sort keys %hash) {
	my @mts=keys $hash{$key};
	my $begin=pop @mts;
	push @{$merge{$key}{$begin}},$begin;
	delete $hash{$key}{$begin};
	my $n=1;
	while ($n) {
		my @temp_mts=keys $hash{$key};
		if (@temp_mts==0) {
			last;
		}
		foreach my $item (@temp_mts) {
			my @arr1=split//,$item;
			my $flag=0;
			foreach my $entry (keys $merge{$key}) {
				my $count;
				my @temp=@{$merge{$key}{$entry}};
				foreach my $e (@temp) {
					my @arr2=split//,$e;
					$count=0;
					foreach my $i (0..$#arr2) {
						if ($arr1[$i] ne $arr2[$i]) {
							$count++;
						}
						if ($count>2) {
							last;
						}
					}
					if ($count>2) {
						last;
					}
				}
				if ($count>2) {
					next;
				}else {
					$flag=1;
					push @{$merge{$key}{$entry}},$item;
					delete $hash{$key}{$item};
				}
			}
			if ($flag==0) {
				push @{$merge{$key}{$item}},$item;
				delete $hash{$key}{$item};
			}
		}
	}
}


open IN, $exact_xls or die "Can't open '$exact_xls': $!\n";
open OUT,">","$out\_ratio_exact.xls"
	or die "Can't open '$out\_ratio_exact.xls': $!\n";
while (my $line=<IN>) {
	#site1   site2     uniq_sum      fusion_reads_num        fusion_mt_num   fusion_reads    fusion_mt_info
	#chr17:41223109|BRCA1:exon:14    chr12:20153296|null   8      8       2       GGAAGAGTTTGC:MN00129:11:000H23NKW:1:23109:4541:4336,GGAAGAGTTTGC:MN00129:11:000H23NKW:1:21109:1743:3468,TCGACAAGGATC:MN00129:11:000H23NKW:1:21110:18119:15243,GGAAGAGTTTGC:MN00129:11:000H23NKW:1:23106:11055:11029,GGAAGAGTTTGC:MN00129:11:000H23NKW:1:21108:6158:18886,GGAAGAGTTTGC:MN00129:11:000H23NKW:1:13104:8261:12974,GGAAGAGTTTGC:MN00129:11:000H23NKW:1:11102:1889:8267,GGAAGAGTTTGC:MN00129:11:000H23NKW:1:22104:7674:6365   (GGAAGAGTTTGC:7);(TCGACAAGGATC:1)
	chomp $line;
	if ($line=~/^site/) {
		next;
	}
	my ($site1,$site2,$uniq_sum,$f_reads_num,$f_mt_num,$f_reads,$f_mt)=(split/\s+/,$line)[0,1,2,3,4,5,6];
	my $chr_pos1=(split/\|/,$site1)[0];
	my $chr_pos2=(split/\|/,$site2)[0];
	if ($f_reads_num<$plus_reads or $uniq_sum<$uniq) {
		next;
	}
	my (@mt1,@mt2,$nomal_all_pos1,$nomal_all_pos2,$ratio1,$ratio2);
	if (exists $nomal_all{$chr_pos1}) {
		$nomal_all_pos1=$nomal_all{$chr_pos1};
		@mt1=keys $merge{$chr_pos1};
	}else {
		$nomal_all_pos1=0;
	}
	my $ratio_value1=$f_reads_num*100/($nomal_all_pos1+$f_reads_num);
	if ($ratio_value1==0 or $ratio_value1==100) {
		$ratio1=$ratio_value1;
	}else {
		$ratio1=sprintf "%.3f",$ratio_value1;
	}
	my @info1=&plusmt(\%nomal_num,$chr_pos1,$f_reads_num,$f_mt,0.9);
	my @plus_mt1=@{$info1[0]};
	my $p_plusmt1_value=@plus_mt1*100/(@mt1+$f_mt_num);
	my $p_plusmt1;
	if ($p_plusmt1_value==0 or $p_plusmt1_value==100) {
		$p_plusmt1=$p_plusmt1_value;
	}else {
		$p_plusmt1=sprintf "%.3f",$p_plusmt1_value;
	}
	if ($ratio1<$r_value) {
		next;
	}
	if (@plus_mt1<$plus_mt) {
		next;
	}
	if (exists $nomal_all{$chr_pos2}) {
		$nomal_all_pos2=$nomal_all{$chr_pos2};
		@mt2=keys $merge{$chr_pos2};
	}else {
		$nomal_all_pos2=0;
	}
	my $ratio_value2=$f_reads_num*100/($nomal_all_pos2+$f_reads_num);
	if ($ratio_value2==0 or $ratio_value2==100) {
		$ratio2=$ratio_value2;
	}else {
		$ratio2=sprintf "%.3f",$ratio_value2;
	}
	my @info2=&plusmt(\%nomal_num,$chr_pos2,$f_reads_num,$f_mt,0.9);
	my @plus_mt2=@{$info2[0]};
	my $p_plusmt2_value=@plus_mt2*100/(@mt2+$f_mt_num);
	my $p_plusmt2;
	if ($p_plusmt2_value==0 or $p_plusmt2_value==100) {
		$p_plusmt2=$p_plusmt2_value;
	}else {
		$p_plusmt2=sprintf "%.3f",$p_plusmt2_value;
	}
	my $plusmts1=join ";",@plus_mt1;
	my $plusmts2=join ";",@plus_mt2;
	my $want = "point1: $site1\t$ratio1\t$p_plusmt1\t".(scalar @plus_mt1)."\t"
				."$nomal_all_pos1\t".(scalar @mt1)."\t$f_reads_num\t"
				."$f_mt_num\t$plusmts1\t$f_mt\t$f_reads\n"
				."point2: $site2\t$ratio2\t$p_plusmt2\t".(scalar @plus_mt2)."\t"
				."$nomal_all_pos2\t".(scalar @mt2)."\t$f_reads_num\t"
				."$f_mt_num\t$plusmts2\t$f_mt\t$f_reads\n";
	print OUT $want;
}
close IN;
close OUT;

open IN, $vague_xls or die "Can't open '$vague_xls': $!\n";
open OUT,">","$out\_ratio_vague.xls"
	or die "Can't open '$out\_ratio_vague.xls': $!\n";
while (my $line=<IN>) {
	#site1   site2     uniq_sum      fusion_reads_num        fusion_mt_num   fusion_reads    fusion_mt_info
	#chr7:92234203|null      chr5:108719784|PJA2:intron:1     5     5       1       GGGGGGTTCGGG:MN00129:11:000H23NKW:1:21110:8154:14187,GGGGGGTTCGGG:MN00129:11:000H23NKW:1:21106:3141:6682,GGGGGGTTCGGG:MN00129:11:000H23NKW:1:11102:7122:15297,GGGGGGTTCGGG:MN00129:11:000H23NKW:1:21102:2681:14376,GGGGGGTTCGGG:MN00129:11:000H23NKW:1:11102:7407:12441 (GGGGGGTTCGGG:5)
	chomp $line;
	if ($line=~/^site/) {
		next;
	}
	my ($site1,$site2,$uniq_sum,$f_reads_num,$f_mt_num,$f_reads,$f_mt)=(split/\s+/,$line)[0,1,2,3,4,5,6];
	my $chr_pos1=(split/\|/,$site1)[0];
	my $chr_pos2=(split/\|/,$site2)[0];
	if ($f_reads_num<$plus_reads or $uniq_sum<$uniq) {
		next;
	}
	my (@mt1,@mt2,$nomal_all_pos1,$nomal_all_pos2,$ratio1,$ratio2);
	if (exists $nomal_all{$chr_pos1}) {
		$nomal_all_pos1=$nomal_all{$chr_pos1};
		@mt1=keys $merge{$chr_pos1};
	}else {
		$nomal_all_pos1=0;
	}
	my $ratio_value1=$f_reads_num*100/($nomal_all_pos1+$f_reads_num);
	if ($ratio_value1==0 or $ratio_value1==100) {
		$ratio1=$ratio_value1;
	}else {
		$ratio1=sprintf "%.3f",$ratio_value1;
	}
	my @info1=&plusmt(\%nomal_num,$chr_pos1,$f_reads_num,$f_mt,0.9);
	my @plus_mt1=@{$info1[0]};
	my $p_plusmt1_value=@plus_mt1*100/(@mt1+$f_mt_num);
	my $p_plusmt1;
	if ($p_plusmt1_value==0 or $p_plusmt1_value==100) {
		$p_plusmt1=$p_plusmt1_value;
	}else {
		$p_plusmt1=sprintf "%.3f",$p_plusmt1_value;
	}
	if ($ratio1<$r_value) {
		next;
	}
	if (@plus_mt1<$plus_mt) {
		next;
	}
	if (exists $nomal_all{$chr_pos2}) {
		$nomal_all_pos2=$nomal_all{$chr_pos2};
		@mt2=keys $merge{$chr_pos2};
	}else {
		$nomal_all_pos2=0;
	}
	my $ratio_value2=$f_reads_num*100/($nomal_all_pos2+$f_reads_num);
	if ($ratio_value2==0 or $ratio_value2==100) {
		$ratio2=$ratio_value2;
	}else {
		$ratio2=sprintf "%.3f",$ratio_value2;
	}
	my @info2=&plusmt(\%nomal_num,$chr_pos2,$f_reads_num,$f_mt,0.9);
	my @plus_mt2=@{$info2[0]};
	my $p_plusmt2_value=@plus_mt2*100/(@mt2+$f_mt_num);
	my $p_plusmt2;
	if ($p_plusmt2_value==0 or $p_plusmt2_value==100) {
		$p_plusmt2=$p_plusmt2_value;
	}else {
		$p_plusmt2=sprintf "%.3f",$p_plusmt2_value;
	}
	my $plusmts1=join ";",@plus_mt1;
	my $plusmts2=join ";",@plus_mt2;
	my $want = "point1: $site1\t$ratio1\t$p_plusmt1\t".(scalar @plus_mt1)."\t"
				."$nomal_all_pos1\t".(scalar @mt1)."\t$f_reads_num\t"
				."$f_mt_num\t$plusmts1\t$f_mt\t$f_reads\n"
				."point2: $site2\t$ratio2\t$p_plusmt2\t".(scalar @plus_mt2)."\t"
				."$nomal_all_pos2\t".(scalar @mt2)."\t$f_reads_num\t"
				."$f_mt_num\t$plusmts2\t$f_mt\t$f_reads\n";
	print OUT $want;
}
close IN;
close OUT;

system "date";

sub plusmt {
	my ($n_mtreads_hash,$pos,$f_reads_num,$f_mt,$p_cutoff) = @_;
	my @plus_mt;
	my @temp=split /;/,$f_mt;
	foreach my $i (@temp) {
		$i=~s/^\(//;
		$i=~s/\)$//;
		my @arr=split /,/,$i;
		my $fusion=0;
		my @array;
		foreach my $e (@arr) {
			my ($mt,$num)=split /:/,$e;
			$fusion+=$num;
			push @array,$mt;
		}
		my $nomal=0;
		foreach my $m (@array) {
			if (exists $$n_mtreads_hash{$pos}{$m}) {
				$nomal+=$$n_mtreads_hash{$pos}{$m};
			}else {
				$nomal+=0;
			}
		}
		my $p_mt=$fusion/($fusion+$nomal);
		if ($p_mt>$p_cutoff) {
			push @plus_mt,"($i)";
		}
	}
	return (\@plus_mt);
}


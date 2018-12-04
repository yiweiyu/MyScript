#!/usr/bin/perl -w

#*****************************************************************************
# FileName: mt_purity.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-12-13
# Description: This code is to calculate the pruity of mt.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 <sam> <all_lis> <out_prefix>
USAGE
if (@ARGV!=3) {
	die $usage;
}
my $sam=shift;
my $all_lis=shift;
my $out_prefix=shift;

open SAM, $sam or die "Can't open '$sam': $!\n";
my (%mark,%count);
while (my $line=<SAM>) {
	chomp $line;
	if ($line=~/^@/ | $line=~/^\s+$/) {
		next;
	}
	#CGGCCGCGCTCG:MN00129:11:000H23NKW:1:23110:12331:20229   77      *       0       0       *       *       0       0       AGTGGATACTTATATCTTTCTCAAGTTTTAGAAAGTTTTCTATTATTGGCTGGGTGCAGTGGCTCATGCCTGTAATCCCAGCATTTTGGGAGGCCGAGGCAGGTGGATCATGAGGTCAGAAGAT    AAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6FFFFFFFFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF    YT:Z:UP
	#CGGCCGCGCTCG:MN00129:11:000H23NKW:1:23110:12331:20229   141     *       0       0       *       *       0       0       GCCTCAGCCTCCCAAGTAGATGGGACTACAGGTGCCCGCCACC     FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFAFFFFFAFF     YT:Z:UP
	#TATATCCAGCAA:MN00129:11:000H23NKW:1:23110:21779:20255   99      chr12_56489358_56489758 103     42      93M     =       145     93      TGACAATGGCTTTGACAGTGATAGCAGGATTGGTAGTGATTTTCATGATGCTGGGCGGCACTTTTCTCTACTGGCGTGGGCGCCGGATTCAGA   FFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF   AS:i:0  XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:93 YS:i:0  YT:Z:CP
	#TATATCCAGCAA:MN00129:11:000H23NKW:1:23110:21779:20255   147     chr12_56489358_56489758 145     42      51M     =       103     -93     TCATGATGCTGGGCGGCACTTTTCTCTACTGGCGTGGGCGCCGGATTCAGA     FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFFFFFFFFFFFFFFFF     AS:i:0  XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:51 YS:i:0  YT:Z:CP
	my ($read,$ref,$Tlen)=(split /\t/ , $line)[0,2,8];
	if ($Tlen==0) {
		next;
	}
	if (exists $mark{$read}) {
		next;
	}else {
		$mark{$read}=1;
	}
	$Tlen=abs $Tlen;
	if ($Tlen!=0) {
		my $mt=(split/:/,$read)[0];
		$count{$mt}{$ref}++;
	}else {
		next;
	}
}
close SAM;

open IN, $all_lis or die "Can't open '$all_lis': $!\n";
open OUT,">","$out_prefix.purity.xls"
	or die "Can't open '$out_prefix.purity.xls': $!\n";
my $n=0;
while (my $line=<IN>) {
	#/share/data1/zhangshehuan/Script/test/mt_Y2/y2_new/what/Y2_S10_L001/mt_all/TAGAGGCGCCTG.fq      15
	#/share/data1/zhangshehuan/Script/test/mt_Y2/y2_new/what/Y2_S10_L001/mt_all/TTTATATTAGGC.fq      11
	chomp $line;
	my ($file,$read_num)=(split/\s+/,$line)[0,1];
	my $mt=(split/\//,$file)[-1];
	$mt=~s/.fq$//;
	if (exists $count{$mt}) {
		my @temp=sort {$count{$mt}{$b}<=>$count{$mt}{$a}} keys $count{$mt};
		my $purity=sprintf "%.3g",$count{$mt}{$temp[0]}/$read_num;
		if ($purity>0.9) {
			$n++;
			print OUT "$mt\t$purity=$count{$mt}{$temp[0]}/$read_num\n";
		}
	}
}
close IN;
close OUT;
print "$n\n";

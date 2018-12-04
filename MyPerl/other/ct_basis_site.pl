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
	Usage: perl $0 <bed> <sam> <out_prefix>
USAGE
if (@ARGV!=3) {
	die $usage;
}
my $bed=shift;
my $sam=shift;
my $out=shift;

open IN, $bed or die "Can't open '$bed': $!\n";
my %bedsite;
while (my $line=<IN>) {
	#EML4    chr2    6       plus    42491845        42491871        ALK     chr2    19      minus   29448326        29448431
	if ($line=~/^\s+$/) {
		next;
	}
	chomp $line;
	my ($chr1,$start1,$stop1,$chr2,$start2,$stop2)=(split/\s+/,$line)[1,4,5,7,10,11];
	#foreach my $i ($start1..$stop1) {
	#	$bedsite{$chr1}{$i}=0;
	#}
	foreach my $i ($start2..$stop2) {
		$bedsite{$chr2}{$i}=0;
	}
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
	#TATATCCAGCAA:MN00129:11:000H23NKW:1:23110:21779:20255   99      chr12_56489358_56489758 103     42      93M     =       145     93      TGACAATGGCTTTGACAGTGATAGCAGGATTGGTAGTGATTTTCATGATGCTGGGCGGCACTTTTCTCTACTGGCGTGGGCGCCGGATTCAGA   FFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF   AS:i:0  XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:93 YS:i:0  YT:Z:CP
	#TATATCCAGCAA:MN00129:11:000H23NKW:1:23110:21779:20255   147     chr12_56489358_56489758 145     42      51M     =       103     -93     TCATGATGCTGGGCGGCACTTTTCTCTACTGGCGTGGGCGCCGGATTCAGA     FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFFFFFFFFFFFFFFFF     AS:i:0  XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:51 YS:i:0  YT:Z:CP
	my ($name,$ref,$start,$Tlen)=(split /\t/ , $line)[0,2,3,8];
	my ($chr,$refstart)=(split /_/,$ref)[0,1];
	unless (defined $refstart) {
		$refstart=0;
	}
	if ($Tlen==0 or !exists $bedsite{$chr}) {
		next;
	}
	unless (exists $mark{$name}) {
		$pre_start{$name}=$start;
		$mark{$name}=1;
		next;
	}
	my $matchstart;
	if ($start<$pre_start{$name}) {
		$matchstart=$start;
	}else {
		$matchstart=$pre_start{$name};
	}
	$Tlen=abs $Tlen;

	my $begin=$refstart+$matchstart-1;
	my $stop=$begin+$Tlen-1;
	foreach my $keys (keys $bedsite{$chr}) {
		if ($keys>=$begin && $keys<=$stop) {
			$bedsite{$chr}{$keys}++;
		}
	}
}
close SAM;

open OUT, ">$out" or die "Can't open '$out': $!\n";
foreach my $key (keys %bedsite) {
	foreach my $subkey (sort{$bedsite{$key}{$b}<=>$bedsite{$key}{$a}} keys $bedsite{$key}) {
		if ($bedsite{$key}{$subkey}>=1000) {
			print OUT "$key\t$subkey\t$bedsite{$key}{$subkey}\n";
		}
	}
}
close OUT;

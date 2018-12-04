#!/usr/bin/perl -w

#*****************************************************************************
# FileName: count_focusgenes_depth.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2018-02-02
# Description: This code is to count bed site depth.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 
		<bed> <sam> <out>
USAGE
if (@ARGV!=3) {
	die $usage;
}
my $bed=shift;
my $sam=shift;
my $out=shift;

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
	if (!exists $bedsite{$chr}) {
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
	foreach my $e ($begin..$stop) {
		if (exists $bedsite{$chr}{$e}) {
			$mark{$name}=1;
			$nomal_all{"$chr:$e"}++;
			my $mt=(split /:/,$name)[0];
			$hash{"$chr:$e"}{$mt}=1;
			$nomal_num{"$chr:$e"}{$mt}++;
		}
	}
}
close SAM;

foreach my $k (keys %nomal_all) {
	if ($nomal_all{$k}<1800) {
		delete $nomal_all{$k};
		delete $hash{$k};
	}
}

system "date";
=cut
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

=cut

open OUT,">","$out\_bed_depth.xls"
	or die "Can't open '$out\__bed_depth.xls': $!\n";
foreach my $key (keys %nomal_all) {
	my @mts=keys $hash{$key};
	#my @mts=keys $merge{$key};
	print OUT "$key\t$nomal_all{$key}\t".(scalar @mts)."\n";
}
close OUT;

system "date";



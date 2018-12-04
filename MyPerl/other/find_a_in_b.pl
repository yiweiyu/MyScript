#!/usr/bin/perl

#*****************************************************************************
# FileName: find_a_in_b.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-30
# Description: This code is to find the files in the B which contain sequences in A.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

if (@ARGV!=3) {
	die "	Usage: perl $0 <afile> <bfile> <out>\n";
}
my $afile=shift;
my $bfile=shift;
my $out=shift;

my %hash;
open IN, "$afile" or die "Can't open '$afile': $!";
while (my $line=<IN>) {
	#Acinetobacter baumannii °¢Ë¾Ã×ÐÇ;Çì´óÃ¹ËØ;Î÷ËÕÃ¹ËØ;     astromicin;gentamicin;sisomicin;        aac(3)-I        CelLoud136 CelLoud137 CelLoud138 CelLoud139 CelLoud140 CelLoud141 CelLoud142 CelLoud143 CelLoud144 CelLoud145 CelLoud146 CelLoud147 CelLoud148 CelLoud149 CelLoud150 CelLoud151 CelLoud152 CelLoud153 CelLoud154        aac(3)-Ia aac(3)-Ia aac(3)-Ia aac(3)-Ia aac(3)-Ia aac(3)-Ia aac(3)-Ia aac(3)-Ia aac(3)-Ia aac(3)-Ia aac(3)-Ia aac(3)-Ia aac(3)-Ia aac(3)-Ia aac(3)-Ia aac(3)-Ia aac(3)-Ia aac(3)-Ia aac(3)-Ia   19      110
	chomp $line;
	my $info=(split/\t/,$line)[-4];
	my @names=split /\s+/,$info;
	foreach my $item (@names) {
		$hash{$item}=1;
	}
}
close IN;

my @ha=keys %hash;
my $h=@ha;
print "all: $h\n";
open IN, "$bfile" or die "Can't open '$bfile': $!";
open OUT, ">$out" or die "Can't open '$out': $!";
print OUT "file\tsum\tbaoman\tbmID\n";
#file    seq_num seq_names
<IN>;
while (my $line=<IN>) {
	#1.fa    2       CelLoud3863,CelLoud3862,
	chomp $line;
	my ($file,$sum,$seqnms)=(split/\s+/,$line)[0,1,2];
	my @seqs=split/,/,$seqnms;
	my $flag=0;
	my $i=0;
	my $info="";
	foreach my $item (@seqs) {
		if (exists $hash{$item}) {
			$i++;
			$flag=1;
			$info.="$item,";
		}
	}
	if ($flag==1) {
		print OUT "$file\t$sum\t$i\t$info\n";
	}

}
close IN;
close OUT;

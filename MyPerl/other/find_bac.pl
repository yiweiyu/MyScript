#!/usr/bin/perl

#*****************************************************************************
# FileName: find_bac.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-7-3
# Description: This code is to find the files in the B which contain bac sequences.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

if (@ARGV!=4) {
	die "	Usage: perl $0 <bacs> <afile> <bfile> <out>\n";
}
my $bacs=shift;
my $afile=shift;
my $bfile=shift;
my $out=shift;
my %bsi;
open IN, "$bacs" or die "Can't open '$bacs': $!";
while (my $line=<IN>) {
	chomp $line;
	my ($nickname,$name)=(split/\t/,$line)[0,-1];
	$name=~s/\s+$//;
	$bsi{$name}="$name($nickname)";
}
close IN;
my @bacnames=keys %bsi;

my %hash;
open IN, "$afile" or die "Can't open '$afile': $!";
while (my $line=<IN>) {
	#Abiotrophia defectiva   bacitracin;     bacA    CelLoud48 CelLoud49     bacA bacA       2       1
	chomp $line;
	my ($bacinfo,$info)=(split/\t/,$line)[0,-4];

	my ($name1,$name2)=(split/\s+/,$bacinfo)[0,1];
	my $bac;
	if ($name2) {
		my $realname2=(split/\/|,/,$name2)[0];
		$bac="$name1 $realname2";
	}else {
		$bac="$name1";
	}
	$bac=~s/(\b\w+\b)$/lcfirst($&)/e;
	$bac=~s/^\b\w+\b/ucfirst($&)/e;
	if ($bac eq "Acinetobacter baumanii") {
		$bac="Acinetobacter baumannii";
	}elsif ($bac eq "Klebsiella pneumonia") {
		$bac="Klebsiella pneumoniae";
	}elsif ($bac eq "Staphylococcus aureu") {
		$bac="Staphylococcus aureus";
	}
	my @names=split/\s+/,$info;
	foreach my $item (@names) {
		$hash{$bac}{$item}=1;
	}
}
close IN;

open OUT, ">$out.all" or die "Can't open '$out.all': $!";
print OUT "file\tsum";
my $all=0;
foreach my $item (@bacnames) {
	if (exists $hash{$item}) {
		my @arry=keys $hash{$item};
		my $a=@arry;
		$all+=$a;
		print "$item: $a\n";
	}else {
		print "$item: 0\n";
	}
	print OUT "\t$bsi{$item} sum\t$bsi{$item} ID";
}
print "all: $all\n";
print OUT "\n";

open IN, "$bfile" or die "Can't open '$bfile': $!";
#file    seq_num seq_names
<IN>;
while (my $line=<IN>) {
	#1.fa    2       CelLoud3863,CelLoud3862,
	chomp $line;
	my ($file,$sum,$seqnms)=(split/\s+/,$line)[0,1,-1];
	my @seqs=split/,/,$seqnms;
	my %count=();
	my %info=();
	my $i=0;
	foreach my $bacname (@bacnames) {
		foreach my $seqname (@seqs) {
			if (exists $hash{$bacname}{$seqname}) {
				$count{$bacname}++;
				$info{$bacname}.="$seqname,";
			}
		}
	}

	print OUT "$file\t$sum";
	foreach my $bacname (@bacnames) {
		my ($mark1,$mark2)=(split/\s+/,$bacname)[0,1];
		if (exists $count{$bacname}) {
			open OUT1, ">>$out.$mark1.$mark2" or die "Can't open '$out.$mark1.$mark2': $!";
			print OUT1 "$file\t$sum\t$count{$bacname}\t$info{$bacname}\n";
			close OUT1;
			print OUT "\t$count{$bacname}\t$info{$bacname}";
		}else {
			print OUT "\t0\t-";
		}
	}
	print OUT "\n";
}
close IN;
close OUT;

#!/usr/bin/perl

#*********************************************************************************
# FileName: given_num2lis.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-16
# Description: This code is to generate list files based on given number and given
#              input dirfile, with given number rows in each list file.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

if (@ARGV!=3) {
	die "	Usage: $0 <dirfile> <numb> <outdir>\n";
}

my $in=shift;
my $num=shift;
my $outdir=shift;
open IN,"$in" or die "Can't open $in: $!\n";
my ($temp,$dir,$number,$list,@array);
my $n=0;
my $want="";
while (<IN>) {
	#BL201701001130  /share/data/file/100/20170331/17033106175654.tar.gz
	#BL16118 /share/data/file/126/20160831/16083104339515.tar.gz
	chomp $_;
	$temp=$_;
	$dir=(split/\s+/,$temp)[1];
	$want.="$dir,";
	$n++;
	if (($n%$num)!=0) {
		next;
	}

	$number=int($n/$num);
	$list=$outdir."/list.".$number;
	@array=split/,/,$want;
	open OUT,">$list" or die "Can't open $list: $!\n";
	foreach my $element (@array) {
		print OUT "$element\n";
	}
	close OUT;
	$want="";
}
close IN;

if ($want ne "") {
	$number=int($n/$num)+1;
	$list=$outdir."/list.".$number;
	@array=split/,/,$want;
	open OUT,">$list" or die "Can't open $list: $!\n";
	foreach my $element (@array) {
		print OUT "$element\n";
	}
	close OUT;
	$want="";
}

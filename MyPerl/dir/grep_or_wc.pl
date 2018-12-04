#!/usr/bin/perl

#*****************************************************************************
# FileName: grep_or_wc.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-19
# Description: This code is to print the number of sequences of each file under 
#              given dir to the output. if the number of sequences is 0 in sone file,
#              then print the number of lines of this file to output.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#Usage:
#    perl $0 <dir> <out>
#*****************************************************************************

use strict;
use warnings;

if (@ARGV!=2) {
	die "	Usage: perl $0 <dir> <out>\n";
}

my $dir=$ARGV[0];
my $out=$ARGV[1];

my @arry1=glob "$dir/*";
my @arry2=glob "$dir/*/*";
my @arry=(@arry1,@arry2);

open OUT,">$out.database" or die "Can not write $out.database: $!\n";
my ($want,@temp);
foreach my $element (@arry) {
	$want=`grep ">" $element |wc -l`;
	@temp=split /\s+/,$want;
	if ($temp[0]!=0) {
		chomp $want;
		print OUT "$want\t$element\n";
	}else {
		$want=`wc -l $element`;
		chomp $want;
		my @temp=split (/\s+/,$want,2);
		print OUT "$temp[0]\t$temp[1]\n";
	}
}
close OUT;

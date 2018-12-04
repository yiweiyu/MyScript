#!/usr/bin/perl

#*****************************************************************************
# FileName: get_name.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-19
# Description: This code is print the names under given dir to output.
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

open OUT,">$out.software" or die "Can not write $out.software: $!\n";
my @arry=glob "$dir/*";
foreach my $element (@arry) {
	my @temp=split /\//,$element;
	print OUT "$temp[-1]\n";
}
close OUT;

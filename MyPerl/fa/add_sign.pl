#!/usr/bin/perl

#*********************************************************************************
# FileName: add_sign.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-28
# Description: This code is to add ">" to the read name which does not begin with ">"
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

if (@ARGV!=2) {
	die "	Usage: perl $0 <in> <out>\n";
}
my $in=shift;
my $out=shift;

open OUT,">$out" or die "Can't open '$out': $!";
open IN, "$in" or die "Can't open '$in': $!";
while (my $line=<IN>) {
	chomp $line;
	if ($line=~/CelLoud/) {
		print OUT ">$line\n";
	}else {
		print OUT "$line\n";
	}
}
close IN;
close OUT;

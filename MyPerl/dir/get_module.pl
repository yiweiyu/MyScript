#!/usr/bin/perl

#*****************************************************************************
# FileName: grep_module.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-19
# Description: This code is to print all modules under given dir to output.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#Usage:
#    perl $0 <list> <outdir>
#*****************************************************************************

use strict;
use warnings;

if (@ARGV!=2) {
	die "	Usage: perl $0 <dir> <out>\n";
}

my $dir=$ARGV[0];
my $out=$ARGV[1];

my @arry=glob "$dir/*";
my %hash;
foreach my $element (@arry) {
	system("cat $element |tr -d '\r' > $element.temp")&& error('cat');
	system("mv $element.temp $element")&& error('mv');
	if ($element=~/pl$/) {
		my @temp=`grep "^use" $element`;
		foreach my $module (@temp) {
			$hash{$module}++;
		}
	}elsif ($element=~/py$/) {
		my @temp=`grep "^import" $element`;
		foreach my $module (@temp) {
			$hash{$module}++;
		}
	}
}

open OUT,">$out.module" or die "Can not write $out.module: $!\n";
my @want=keys %hash;
@want =sort @want;
print OUT "@want";
close OUT;

sub error {
	print "$_[0] in error!\n";
	exit;
}

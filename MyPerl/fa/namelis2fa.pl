#!/usr/bin/perl

#*********************************************************************************
# FileName: namelis2fa.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-7-13
# Description: This code is to get fa seq based on given namelis.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

if (@ARGV!=3) {
	die "Usage: perl $0 <in_fafile> <in_namelis> <out_faseq>\n"
}
my $in=$ARGV[0];
my $namelis=$ARGV[1];
my $out=$ARGV[2];

my %hash;
open (IN, "$namelis") or die "Can not open $namelis\n";
while (my $line=<IN>) {
	chomp $line;
	my @temp=split /\s+/,$line;
	my $name=$temp[0];
	if ($name=~/^>/) {
		$name=~s/^>//;
	}
	$hash{$name}=1;
}
close IN;

$/=">";
open (IN, "$in") or die "Can not open $in\n";
open (OUT, ">$out") or die "Can not open $out\n";
<IN>;
while (my $line=<IN>) {
	my ($head,$seq)=(split /\n/,$line,2)[0,1];
	chomp $seq;
	if (exists $hash{$head}) {
		print OUT ">$head\n$seq";
	}
}
close IN;
close OUT;
$/="\n";



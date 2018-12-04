#!/usr/bin/perl

#*********************************************************************************
# FileName: givennum_2_randomfa.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-19
# Description: This code is to get random fa records based on the input numbers
#              and the input parent fa file.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;
if (@ARGV!=4) {
	die "	Usage: perl $0 <infa> <sum> <wantnum> <out>\n";
}
my $in=shift;
my $sum=shift;
my $wantnum=shift;
my $out=shift;

$/=">";
open OUT,">$out" or die "Can't open '$out': $!";
open OUT1,">$out.info" or die "Can't open '$out.info': $!";
open IN, "$in" or die "Can't open '$in': $!";
my %hash=&createRandNum($sum,$wantnum);
my $n=0;
<IN>;
while (my $line=<IN>) {
	chomp $line;
	my ($token,$seq)=(split /\n/,$line,2)[0,1];
	if (exists $hash{$n}) {
		print OUT ">$token\n$seq";
		print OUT1 ">$token\n";
	}
	$n++;
}
close IN;
close OUT;
$/="\n";

sub createRandNum{
	my ($MaxNum,$MaxCount) = @_;
	my $i = 0;
	my %rand = ();
	my $no;
	while (1)
	{
		$no = int(rand($MaxNum));
		if (!exists $rand{$no}){
			$rand{$no} = 1;
			$i++;
		}
		last if ($i >= $MaxCount);
	}
	return %rand;
}

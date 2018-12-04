#!/usr/bin/perl

#*********************************************************************************
# FileName: files_whether_eq.all.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-11-16
# Description: This code is to compare two files to see if they are identical.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

if (@ARGV!=3) {
	die "	Usage: perl $0 <in_1> <in_2> <out>\n";
}

my $in_1=shift;
my $in_2=shift;
my $out=shift;

open OUT, ">$out.warning" or die "Can not write $out.warning: $!\n";
my @want=&find_diff($in_1,$in_2);
my $flag=shift @want;
if ($flag==1) {
	print OUT "different line:\n";
	foreach my $i (@want) {
		print OUT "\t$i\n";
	}
}
close OUT;

sub find_diff() {
	my ($rec1,$ref1) = @_;
	open(A, "$rec1") or die "Can not open 1 $rec1: $!\n";
	open(B, "$ref1") or die "Can not open 2 $ref1: $!\n";
	my $diff;
	my ($n,$mark)=(0)x2;
	my @info;
	while (my $line_a=<A>) {
		$n++;
		my $line_b=<B>;
		my @a=split(/\s+/,$line_a);
		my @b=split(/\s+/,$line_b);
		my $a=@a;
		my $b=@b;
		$diff=0;  #0 means they are identical£¬1 means they are different.
		if ($a<$b) {
			$a=$b;
		}
		for (0..$a-1) {
			if ($a[$_] eq $b[$_]) {
				next;
			}else {
				$diff=1;
				last;
			}
		}
		if ($diff==1) {
			$mark=1;
			push @info,$n;
		}
	}
	close(A);
	close(B);
	unshift @info,$mark;
	return (@info);
}

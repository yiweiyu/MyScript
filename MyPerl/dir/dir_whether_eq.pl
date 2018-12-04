#!/usr/bin/perl

#*****************************************************************************
# FileName: dir_whether_eq.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-19
# Description: This code is to compare the contents between the two folders.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#Usage:
#    perl $0 perl $0 <dir_1> <dir_2> <out>
#*****************************************************************************

use strict;
use warnings;

if (@ARGV!=3) {
	die "	Usage: perl $0 <dir_1> <dir_2> <out>\n";
}

my $dir_1=$ARGV[0];
my $dir_2=$ARGV[1];
my $out=$ARGV[2];

my @arry=glob "$dir_2/*";
my @arry_my=glob "$dir_1/*";
my $r=@arry;
my $m=@arry_my;
if ($r!=$m) {
	print "warning: the total number of files is not same\n";
}
open OUT, ">$out.warning" or die "Can not write $out.warning: $!\n";
foreach my $element (@arry) {
	my @temp=split /\//,$element;
	my $flag=&find_fileindir("$element","$dir_1/$temp[-1]");
	if ($flag==1) {
		print OUT "warning: $element is not equal\n";
	}
}
close OUT;

sub find_fileindir() {
	my ($rec1,$ref1) = @_;
	open(A, "$rec1") or die "Can not open 1 $rec1: $!\n";
	open(B, "$ref1") or die "Can not open 2 $ref1: $!\n";
	my @a=<A>;
	my @b=<B>;
	@a=map{split(/\s+/,$_)}@a;
	@b=map{split(/\s+/,$_)}@b;
	my $a=@a;
	my $b=@b;
	my $diff=0;  #0 means they are identical£¬1 means they are different.
	if ($a<$b) {
		$a=$b;
	}
	for (0..$a-1) {
		if ($a[$_] eq $b[$_]) {
			next;
		}else {
			$diff=1;
			return "$diff";
		}
	}
	return "$diff";
	close(A);
	close(B);
}
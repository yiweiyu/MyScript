#!/usr/bin/perl

#*****************************************************************************
# FileName: merge_group.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-19
# Description: This code is to merge groups of which the stands are relevant.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#Usage:
#    perl $0 <in> <out>
#*****************************************************************************

use strict;
use warnings;

if (@ARGV!=2) {
	die "	Usage: perl $0 <in> <out>\n";

}
my $in=$ARGV[0];
my $out=$ARGV[1];

my $i=1;
my (%hash,@tempt,$name,$direction,%group);
open IN, "$in" or die "Can't open '$in': $!";
while(<IN>){
	$hash{$i}=1;
	chomp;
	if ($_=~/^>/) {
		$i++;
		next;
	}
	@tempt=(split/\s+/,$_);
	$name=$tempt[0];
	$direction=$tempt[1];
	$group{$i}{$name}=$direction;
}
close IN;

my $a=1;
my (@arry,$all,$t,%hs,@tarry,$q,$u,$key, $value);
while ($a==1) {
	@arry=keys %hash;
	$all=@arry;
	$t=pop @arry;

	$hs{$t}=1;
	@tarry=keys $group{$t};
	$q=@tarry;
	if ($all==1) {
		$a=0;
		$hs{$t}=1;
		last;
	}else {
		foreach my $element (@arry) {
			foreach my $item (keys $group{$t}) {
				if (exists $group{$element}{$item}) {
					delete $hash{$element};
					if ($group{$element}{$item} eq $group{$t}{$item}) {
						while (($key, $value) = each $group{$element}) {
							$group{$t}{$key}=$value;
						}
					}elsif ($group{$element}{$item} ne $group{$t}{$item}) {
						while (($key, $value) = each $group{$element}) {
							if ($value eq "+") {
								$group{$t}{$key}="-";
							}elsif ($value eq "-") {
								$group{$t}{$key}="+";
							}
						}
					}
					last;
				}
			}
		}
		@tarry=keys $group{$t};
		$u=@tarry;
		if ($q==$u) {
			delete $hash{$t};
		}
	}
}



open OUT, ">$out" or die "Can't open '$out': $!";
my @arr=keys %hash;
my @ar=keys %hs;
foreach my $element (@ar) {
	while ( ($key, $value) = each $group{$element} ) {
		print OUT "$key \t $value\n";
	}
	print OUT ">\n";
}
close OUT;
my $sum=@arr;
my $num=@ar;
print "$sum-$num\n";

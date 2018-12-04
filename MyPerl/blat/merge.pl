#!/usr/bin/perl

#*****************************************************************************
# FileName: merge.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-29
# Description: This code is to group sumilar subject sequences.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

if (@ARGV!=2) {
	die "	Usage: perl $0 <in> <out>\n";

}
my $in=shift;
my $out=shift;

my (%group,%hash);
open IN, "$in" or die "Can't open '$in': $!";
while (my $line=<IN>) {
	#                      CelLoud2                    CelLoud6943        519          1        519          1        519        519       1013        0.0         99    517/519          0        0/0          0
	#                      CelLoud2                    CelLoud6942        519          1        519          1        519        519       1013        0.0         99    517/519          0        0/0          0
	#                      CelLoud3                       CelLoud3        441          1        441          1        441        441        874        0.0        100    441/441          0        0/0          0
	#                      CelLoud3                     CelLoud780        441          1        441          1        441        441        589     1e-168         91    405/441          0        0/0          0
	#                      CelLoud4                   CelLoud16176        780          1        780          1        780        780       1546        0.0        100    780/780          0        0/0          0
	#                      CelLoud4                     CelLoud592        780          1        780          1        780        780       1546        0.0        100    780/780          0        0/0          0
	my ($Qname,$Sname)=(split/\s+/,$line)[1,2];
	$hash{$Qname}=1;
	$group{$Qname}{$Qname}=1;
	$group{$Qname}{$Sname}=1;
}
close IN;
my @ha=keys %hash;
my $h=@ha;
print "blocks: $h\n";

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
					while (($key, $value) = each $group{$element}) {
						$group{$t}{$key}=1;
					}
					last;
				}
			}
		}
		@tarry=keys $group{$t};
		$u=@tarry;
		if ($q==$u) {
			delete $hash{$t};
			$hs{$t}=1;
		}
	}
}



open OUT, ">$out" or die "Can't open '$out': $!";
my @ar=keys %hs;
my $combine=@ar;
print "combine: $combine\n";
foreach my $element (@ar) {
	while ( ($key, $value) = each $group{$element} ) {
		print OUT "$element\t$key\n";
	}
	print OUT ">\n";
}
close OUT;

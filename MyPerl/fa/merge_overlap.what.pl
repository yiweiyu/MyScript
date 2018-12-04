#!/usr/bin/perl

#*********************************************************************************
# FileName: merge_overlap.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-10-10
# Description: This code is to merge overlap.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;
if (@ARGV!=2) {
	die "\tUsage: $0 <in> <out>\n";
	exit;
}
my $list=shift;
my $out=shift;
open (L,"$list") || die"Can't open $list: $!\n";
my %hash;
while (my $line=<L>) {
	if ($line=~/^\s+$/) {
		next;
	}
	#chr1    11172841        11172993
	#chr1    11174350        11174513
	#chr1    11177065        11177219
	chomp $line;
	my ($chr,$start,$stop)=(split/\s+/,$line)[0,1,2];
	$hash{$chr}{$start}=$stop;
}
close L;

my %want;
foreach my $chr (keys %hash) {
	my $loop=1;
	while ($loop) {
		my @stars=sort (keys $hash{$chr});
		if (@stars==0) {
			last;
		}
		my $mark=0;
		my $object=pop @stars;
		foreach my $item (@stars) {
			if ($object<$item) {
				if ($hash{$chr}{$object}>$item && $hash{$chr}{$object}<$hash{$chr}{$item}) {
					$hash{$chr}{$object}=$hash{$chr}{$item};
					delete $hash{$chr}{$item};
					$mark=1;
					last;
				}elsif ($hash{$chr}{$item}<$hash{$chr}{$object}) {
					delete $hash{$chr}{$item};
					$mark=1;
					last;
				}
			}else {
				if ($hash{$chr}{$item}>$object && $hash{$chr}{$item}<$hash{$chr}{$object}) {
					$hash{$chr}{$item}=$hash{$chr}{$object};
					delete $hash{$chr}{$object};
					$mark=1;
					last;
				}elsif ($hash{$chr}{$object}<$hash{$chr}{$item}) {
					delete $hash{$chr}{$object};
					$mark=1;
					last;
				}
			}
		}
		if ($mark==0) {
			$want{$chr}{$object}=$hash{$chr}{$object};
			delete $hash{$chr}{$object};
		}
	}
}

open (O,">$out") || die"Can't write $out: $!\n";
foreach my $key (keys %want) {
	foreach my $subkey (keys $want{$key}) {
		print O "$key\t$subkey\t$want{$key}{$subkey}\n";
	}
}
close O;



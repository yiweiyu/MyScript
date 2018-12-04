#!/usr/bin/perl
use strict;
use warnings;

my $string=".A+17AGACATCACGATGGATCA+17AGACATCACGATGGATCG+3ATC^K.";
my @arr=split /[+-]/,$string;
my $want;
foreach my $i (@arr) {
	if ($i=~/^([0-9]{1,})/) {
		my $num=$1;
		$i=~s/^$num.{$num}//;
		$want.=$i;
	}else{
		$want.=$i;
	}
}
print "$want\n";

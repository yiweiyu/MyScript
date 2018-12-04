#!/usr/bin/perl
use strict;
use warnings;
my $strat=541;
$strat=$strat-1;
my $str="|:|||||||||++:||++||++|:|||::||:|||++|||||++||++|:||||:::|||";
my @temp=split//,$str;
foreach my $item (@temp) {
	$strat++;
	if ($item eq "+") {
		print "ALDH1A3\t$strat\n";
	}
}


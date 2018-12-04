#!/usr/bin/perl

#*********************************************************************************
# FileName: site_lis2cut_lis.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-16
# Description: This code is to get cut list base on given site list and the length
#              required for front and back cutting.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

if (@ARGV<4) {
	print "Usage: $0 <input> <leftlen> <rightlen> <output>\n";
	exit;
}
my $in=shift;
my $leftlen=shift;
my $rightlen=shift;
my $out=shift;
open (I,"$in")||die"Can't open $in: $!\n";
open (O,">$out")||die"Can't write $out: $!\n";
while (my $line=<I>) {
	#chr7            140453001               140453175               BRAF
	#chr7            140453001               140453175               BRAF
	if ($line=~/^\s+$/) {
		next;
	}
	chomp $line;
	my ($chr,$start,$stop,$name)=(split/\s+/,$line)[0,1,2,3];
	if ($start>$stop) {
		($start,$stop)=($stop,$start);
	}
	my $newstart=$start-$leftlen;
	my $newstop=$stop+$rightlen;
	if (defined $name) {
		print O "$chr\t$newstart\t$newstop\t$name\n";
	}else {
		print O "$chr\t$newstart\t$newstop\n";
	}
}
close I;
close O;

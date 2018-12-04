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
	#rs9327837	chr5	101662158
	#ALK		chr2	29448431	19
	chomp $line;
	my ($name,$chr,$medium,$exon)=(split/\s+/,$line)[0,1,2,3];
	my $ahead=$medium-$leftlen;
	my $behind=$medium+$rightlen;
	if ($exon) {
		print O "$chr\t$ahead\t$behind\t$name|exon$exon\n";
	}else {
		print O "$chr\t$ahead\t$behind\t$name\n";
	}
}
close I;
close O;

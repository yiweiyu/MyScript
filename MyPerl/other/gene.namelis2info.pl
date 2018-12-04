#!/usr/bin/perl

#*****************************************************************************
# FileName: gene.namelis2info.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-8-4
# Description: This code is to get info based on given namelis.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

if (@ARGV!=3) {
	die "\tUsage: $0 <namelis> <info> <out>\n";
	exit;
}

my $namelis=shift;
my $info=shift;
my $out=shift;

my %hash;
open IN, "$namelis" or die "Can't open '$namelis': $!";
while (my $line=<IN>) {
	#SRSF1
	#SPF45
	chomp $line;
	my $gene=(split/\s+/,$line)[0];
	$hash{$gene}=1;
}
close IN;

open IN, "$info" or die "Can't open '$info': $!";
open OUT, ">$out" or die "Can't open '$out': $!";
while (my $line=<IN>) {
	#gene    logFC   logCPM  Pvalue  FDR
	#LHX1|ENSG00000273706|protein_coding     10.86351546     2.671240798     9.63E-05        0.000492898
	#SPANXB1|ENSG00000227234|protein_coding  10.73087856     2.699006173     0.001485501     0.005209273
	chomp $line;
	if ($line=~/^gene/) {
		print OUT "$line\n";
	}else {
		my $name=(split/\|/,$line)[0];
		$name=uc $name;
		foreach my $key (keys %hash) {
			#print OUT "$name\t$key\n";
			if ($name eq $key) {
				#print OUT "$name\t$key\n";
				print OUT "$line\n";
				last;
			}
		}
	}
}
close IN;
close OUT;


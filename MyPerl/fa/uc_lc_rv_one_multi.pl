#!/usr/bin/perl

#*********************************************************************************
# FileName: uc_lc_one_multi.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-12-15
# Description: This code is to change the fa record to given format.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;
use Getopt::Long;

my ($help,$input,$output,$uc,$lc,$rv,$oneline,$multiline);
GetOptions(
	"help|?" => \$help,
	"i:s"  =>\$input,
	"o:s"  =>\$output,
	"uc!"  =>\$uc,
	"lc!" =>\$lc,
	"rv!" =>\$rv,
	"multiline:f" =>\$multiline,
	);

my $usge=<<USAGE;

	Usage: perl $0 
		-i          <input fasta> 
		-o          <output fasta> 
		-multiline  <the number of bases per line> [oneline]
		-rv                                        (option) 
		-uc                                        (option) 
		-lc                                        (option) 

USAGE

if ((defined $help)==1 or (defined $input)==0 or (defined $output)==0) {
	die $usge;
}

$/=">";
open OUT,">$output" or die "Can't open '$output': $!";
open IN, "$input" or die "Can't open '$input': $!";
<IN>;
while (my $line=<IN>) {
	chomp $line;
	my ($name,$seq)=(split /\n/,$line,2)[0,1];
	$seq=~s/\s+//g;
	chomp $seq;
	if (defined $uc) {
		$seq=~tr/atgc/ATGC/;
	}elsif (defined $lc) {
		$seq=~tr/ATGC/atgc/;
	}
	if (defined $rv) {
		$seq=~tr/ACGTacgt/TGCAtgca/;
		$seq=reverse $seq;
	}
	if (defined $multiline) {
		$seq=~s/\s+//g;
		$seq=~s/(.{$multiline})/$1\n/g;
	}
	print OUT ">$name\n$seq\n";
}
close IN;
close OUT;
$/="\n";

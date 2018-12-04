#!/usr/bin/perl

#*********************************************************************************
# FileName: site_format_exception.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-16
# Description: This code is to get the name of the read whose length of upstream or 
#              downstream of the certain site is not equal to the given number.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

if (@ARGV!=3){
	print "Usage: $0 <input> <numb> <output>\n";
	exit;
}
my $in=shift;
my $numb=shift;
my $out=shift;
open (I,"$in")||die"Can't open $in: $!\n";
open (O,">$out")||die"Can't write $out: $!\n";
my ($name,$ahead,$behind,$a,$b,$len);
my $flag='';
while (my $line=<I>) {
	#>gnl|dbSNP|rs7561282|allelePos=501|totalLen=1001|taxid=9606|snpclass=1|alleles='A/G'|mol=Genomic|build=150
	# TAGCTAGTAA GTAGTGGAGC TGAAATTCTA ACCTGGCATT TTGTCTTCAG AAACCATGAT
	# AAGTATTTCC AGTTTGTCCA
	# A
	# TCTTAACATA ATATGAACAA AATGTTCATT TTTTTAGATT GTAAAATGTA ATCACAGCAA
	# ATCAAAACGA ATAGCTAATT
	chomp $line;
	if ($line=~/^\s?>/) {
		if ($flag ne "") {
			$ahead=~s/\s+//g;
			$behind=~s/\s+//g;
			$a=length $ahead;
			$b=length $behind;
			if ($a!=$numb or $b!=$numb) {
				print O "$name\n";
			}
			$ahead="";
			$behind="";
		}
		$name=$line;
		$flag="front";
	}else {
		$line=~s/\s+//g;
		$len=length $line;
		if ($len==1) {
			$flag="back";
		}else {
			if ($flag eq "front") {
				$ahead.=$line;
			}elsif ($flag eq "back") {
				$behind.=$line;
			}
		}
	}
}

if ($flag ne "") {
	$ahead=~s/\s+//g;
	$behind=~s/\s+//g;
	$a=length $ahead;
	$b=length $behind;
	if ($a!=$numb or $b!=$numb) {
		print O "$name\n";
	}
}
close I;
close O;


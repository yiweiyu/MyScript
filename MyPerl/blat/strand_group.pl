#!/usr/bin/perl

#*****************************************************************************
# FileName: strand_group.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-19
# Description: This code is to group subject strains which is determined by query
#              strain.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#Usage:
#    perl $0 <blatpsl> <min-match> <out>
#*****************************************************************************

use strict;
use warnings;

if (@ARGV!=3) {
	die "	Usage: perl $0 <blatpsl> <min-match> <out>\n";
}
my $blatpsl=shift;
my $min_match=shift;
my $out=shift;
my (@tem,$Qname,$match,$blockname,@arry,$element,$tnm,$qnm,$str,%hash);
my $block="";
my $i=0;
my $n=0;
open BLAT, "$blatpsl" or die "Can't open '$blatpsl': $!";
open OUT, ">$out" or die "Can't open '$out': $!";
while(<BLAT>){
	if ($n==0 && $_=~/^psLayout/) {
		$n++;
		next;
	}elsif ($n>0 && $n<4) {
		$n++;
		next;
	}elsif ($n==4) {
		$n=0;
		next;
	}

	@tem=(split/\s+/,$_);
	$match=$tem[0];
	$Qname=$tem[9];

	if ($match <= $min_match) {
		next;
	}elsif ($i==0 && $Qname ne "") {
		$i=1;
		$blockname=$Qname;
		push (@arry,$_);
	}elsif ($i==1 && $Qname eq $blockname) {
		push (@arry,$_);
	}elsif ($i==1 && $Qname ne $blockname) {
		$hash{$blockname}="+";
		print OUT "$blockname\t$hash{$blockname}\n";
		foreach $element (@arry) {
				chomp ($element);
				@tem=(split/\s+/,$element);
				$str=$tem[8];
				$qnm=$tem[9];
				$tnm=$tem[13];
				if ($str eq "+") {
					$hash{$tnm}="+";
					print OUT "$tnm\t$hash{$tnm}\n";
				}elsif ($str eq "-") {
					$hash{$tnm}="-";
					print OUT "$tnm\t$hash{$tnm}\n";
				}
		}
		print OUT ">\n";
		@arry=();
		$blockname=$Qname;
		push (@arry,$_);
	}
}

$hash{$blockname}="+";
print OUT "$blockname\t$hash{$blockname}\n";
foreach $element (@arry) {
		chomp ($element);
		@tem=(split/\s+/,$element);
		$str=$tem[8];
		$qnm=$tem[9];
		$tnm=$tem[13];
		if ($str eq "+") {
			$hash{$tnm}="+";
			print OUT "$tnm\t$hash{$tnm}\n";
		}elsif ($str eq "-") {
			$hash{$tnm}="-";
			print OUT "$tnm\t$hash{$tnm}\n";
		}
}
print OUT ">\n";
close BLAT;
close OUT;

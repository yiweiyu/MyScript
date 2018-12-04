#!/usr/bin/perl

#*********************************************************************************
# FileName: fa2UpDown.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-7-27
# Description: This code is to divide fa into up seq and down seq.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

if (@ARGV!=3) {
	die "	Usage: perl $0 <in> <out> <num>\n";
}
my $in=shift;
my $out=shift;
my $num=shift;
$/=">";
open (IN, "$in") or die "Can not open $in\n";
open (OUT, ">$out") or die "Can not open $out\n";
<IN>;
while (my $line=<IN>) {
	my ($name,$seq)=(split /\n/,$line,2)[0,1];
	chomp $seq;
	$seq=~s/\s+//g;
	my $len=length $seq;
	my ($up,$down);
	if ($len>$num*2) {
		$up=substr($seq, 0, $num);
		$down=substr($seq, -$num,);
	}else {
		my $i=int($len/2);
		$up=substr($seq, 0, $i);
		$down=substr($seq, $i,);
	}
	print OUT ">$name|up\n$up\n>$name|downd\n$down\n";
}
close IN;
close OUT;
$/="\n";

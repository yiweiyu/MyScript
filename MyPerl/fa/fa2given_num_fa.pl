#!/usr/bin/perl

#*********************************************************************************
# FileName: fa2given_num_fa.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-9-20
# Description: This code is to generate fa files based on the given fa file.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;
use Cwd 'abs_path';

if (@ARGV!=3) {
	die "	Usage: $0 <infile> <num> <outprefix>\n";
}

my $in=shift;
my $num=shift;
my $out=shift;
$in=abs_path $in;
$out=abs_path $out;

my ($temp,$dir,$number,$list,@array);
my $n=0;
my $want="";
$/=">";
open IN,"$in" or die "Can't open $in: $!\n";
open LIS,">>$out.lis" or die "Can't open '$out.lis': $!\n";
<IN>;
while (my $line=<IN>) {
	chomp $line;
	$want.="$line!";
	$n++;
	if (($n%$num)!=0) {
		next;
	}
	$number=int($n/$num);
	$list="$out.$number.fa";
	print LIS "$list\n";
	@array=split/!/,$want;
	open OUT,">$list" or die "Can't open $list: $!\n";
	foreach my $element (@array) {
		print OUT ">$element";
	}
	close OUT;
	$want="";
}
close IN;

if ($want ne "") {
	$number=int($n/$num)+1;
	$list="$out.$number.fa";
	print LIS "$list\n";
	@array=split/!/,$want;
	open OUT,">$list" or die "Can't open $list: $!\n";
	foreach my $element (@array) {
		print OUT ">$element";
	}
	close OUT;
	$want="";
}
close LIS;
$/="\n";

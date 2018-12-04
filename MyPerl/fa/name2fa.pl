#!/usr/bin/perl

#*********************************************************************************
# FileName: name2fa_seq.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-9
# Description: This code is to get fa seq based on given name.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

if (@ARGV!=3) {
	die "Usage: perl $0 <in_fafile> <in_faname> <out_faseq>\n"
}
my $in=$ARGV[0];
my $name=$ARGV[1];
my $out=$ARGV[2];
$name=~s/^>//;
$/=">";
open (IN, "$in") or die "Can not open $in\n";
open (OUT, ">$out") or die "Can not open $out\n";
my ($line,$temp,$seq);
<IN>;
while ($line=<IN>) {
	($temp,$seq)=(split /\n/,$line,2)[0,1];
	chomp $seq;
	if ($temp=~/$name/) {
		print OUT ">$temp\n$seq";
	}
}
close IN;
close OUT;
$/="\n";



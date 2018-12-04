#!/usr/bin/perl

#*********************************************************************************
# FileName: cut_lis2cut_fa.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-16
# Description: This code(adapted from /share/data2/wanghaiyin/bin/sequence/cut_seq.pl)
#              is to get cutted fa seq based on given list and the length required for
#              front and back cutting.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;
use Getopt::Long;

my $usage=<<USAGE;
	perl $0 
		-i <in> input fasta
		-o <out> output fasta
		-l <list> cut_list
		-n <numb> the number of bases per line (default 50)
		-h  print help information
USAGE
my ($in,$out,$numb,$list,$help);
GetOptions(
	"i:s"=>\$in,
	"o:s"=>\$out,
	"l:s"=>\$list,
	"n:s"=>\$numb,
	"h!"=>\$help
);
if ((defined $help)==1 or defined($in)==0 or defined($list)==0) {
	die $usage;
}
$out||="$list.cut.fa";
$numb||=50;

open (L,"$list")||die"Can't open $list: $!\n";
my %mark;
while (my $line=<L>) {
	#chr5    101661658       101662658       rs9327837
	chomp $line;
	my @a=split/\s+/,$line;
	my $chr=$a[0];
	if ($chr=~/\:/) {
		$chr=(split(/\:/,$chr))[1];
	}elsif ($chr=~/\|/) {
		$chr=(split(/\|/,$chr))[3];
	}else {
		$chr=$chr;
	}
	my $min=&min($a[1],$a[2]);
	my $length=abs($a[2]-$a[1])+1;
	my $info;
	if (defined $a[3]) {
		my $describe=$a[3];
		$info="$min,$length,$describe";
	}else {
		$info="$min,$length";
	}
	push (@{$mark{$chr}},$info);
}
close L;

$/=">";
open (I,"$in")||die"Can't open $in: $!\n";
open (O,">$out")||die"Can't open $out: $!\n";
while (my $line=<I>) {
	chomp $line;
	if ($line ne "") {
		my $name=(split(/\s+/,$line))[0];
		if ($name=~/\:/) {
			$name=(split(/\:/,$name))[1];
		}elsif ($name=~/\|/) {
			$name=(split(/\|/,$name))[3];
		}else {
			$name=$name;
		}
		if (exists $mark{$name}) {
			my $seq=(split(/\n/,$line,2))[1];
			$seq=~s/\n//g;
			foreach my $item (@{$mark{$name}}) {
				my ($left,$length,$describe)=(split(/,/,$item))[0,1,2];
				my $right=$left+$length-1;
				my $flag;
				if (defined $describe) {
					$flag=$name."_".$left."_".$right."_".$describe;
				}else {
					$flag=$name."_".$left."_".$right;
				}
				my $new_seq=substr($seq,$left-1,$length);
				$new_seq=~s/(.{$numb})/$1\n/g;	#the original code
				#$new_seq=~s/(.{$numb})(.)/$1\n$2\n/g;
				$new_seq=~s/\n$//;
				print O ">$flag\n$new_seq\n";
			}
		}
	}
}
close I;
close O;

sub min {
	my ($x1,$x2)=@_;
	my $min;
	if ($x1 < $x2) {
		$min=$x1;
	}else {
		$min=$x2;
	}
	return $min;
}

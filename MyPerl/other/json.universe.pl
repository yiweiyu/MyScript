#!/usr/bin/perl

#*****************************************************************************
# FileName: json.zsh.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-21
# Description: This code is to get $file_name and $entity_submitter_id from 
#              input file ,then read the $file_name in the current directory
#              to build @normalSamples @tumorSamples and %hash, finally generate 
#              output file based on @normalSamples @tumorSamples and %hash.
# Revision: V1.0.0
# ModifyList:
#    Revision: V1.0.2
#    Modifier: Zhanshehuan
#    ModifyTime: 2017-6-21
#    ModifyReason: use JSON.
#    Revision: V1.0.1
#    Modifier: Zhanshehuan
#    ModifyTime: 2017-6-21
#    ModifyReason: remove $file_id; add warning information;
#                  remove comma in the regular expression of $line.
#Usage:
#    perl $0 <in> <out>
#*****************************************************************************

use strict;
use warnings;
#use FindBin qw($Bin);
#use lib "$Bin/../mypm";
use Data::Dumper;
use JSON;

if (@ARGV!=2) {
	die "	Usage: perl $0 <in> <out>\n";
}
my $in=shift;
my $out=shift;

my $json = new JSON;
my $info;
open IN, "$in" or die "Can't open '$in': $!";
while (my $line=<IN>) {
	$info.=$line;
}
close IN;
my $obj = $json->decode($info);

#printf Dumper($obj)."\n";
my %hash=();
my @normalSamples=();
my @tumorSamples=();
foreach my $item (@{$obj}) {
	my $file_name=$item->{'file_name'};
	$file_name=~s/.gz$//;
	my $entity_submitter_id=$item->{'associated_entities'}->[0]->{'entity_submitter_id'};
	if (-f $file_name) {
		my @idArr=split /-/,$entity_submitter_id;
		if ($idArr[3]=~/^0/) {
			push @tumorSamples, $entity_submitter_id;
		}else{
			push @normalSamples, $entity_submitter_id;
		}
		open (RF,"$file_name") or die "Can not open $file_name: $!\n";
		while (my $line=<RF>) {
			if ($line=~/^\n/ or $line=~/^\_/) {
				next;
			}
			chomp $line;
			my @arr=split /\t/,$line;
			$hash{$arr[0]}{$entity_submitter_id}=$arr[1];
		}
		close RF;
	}
}

open(WF,">$out") or die "Can not open $out: $!\n";
my $normalCount=@normalSamples;
my $tumorCount=@tumorSamples;
print "normal count: $normalCount\n";
print "tumor count: $tumorCount\n";

if ($normalCount==0) {
	print WF "id";
}else {
	print WF "id\t" . join("\t",@normalSamples);
}
print WF "\t" . join("\t",@tumorSamples) . "\n";
foreach my $key(keys %hash) {
	print WF $key;
	foreach my $normal (@normalSamples) {
		print WF "\t" . $hash{$key}{$normal};
	}
	foreach my $tumor (@tumorSamples) {
		print WF "\t" . $hash{$key}{$tumor};
	}
	print WF "\n";
}
close WF;

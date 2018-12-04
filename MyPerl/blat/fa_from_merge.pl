#!/usr/bin/perl

#*****************************************************************************
# FileName: fa_from_merge.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-19
# Description: This code is to print all the sequences of the same group 
#              into one file.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

if (@ARGV!=3) {
	die "	Usage: perl $0 <fafile> <groupfile> <outdir>\n";
}
my $fa=shift;
my $in=shift;
my $out=shift;


my %hash;
$/=">";
open FA, "$fa" or die "Can't open '$fa': $!";
<FA>;
while (my $line=<FA>) {
	chomp $line;
	my ($token,$seq)=(split /\n/,$line,2)[0,1];
	$token=~s/^>//;
	$hash{$token}=$seq;
}
$/="\n";
close FA;
my @a=keys %hash;
my $origin=@a;
print "origin: $origin\n";

my $i=0;
my @arr=();
my (%print,%all);
open IN, "$in" or die "Can't open '$in': $!";
open INFO,">$out/all.info" or die "Can't open $out/all.info: $!\n";
print INFO "file\tseq_num\tseq_names\n";
while (my $line=<IN>) {
	#CelLoud20832    CelLoud20832
	#>
	#CelLoud1399     CelLoud1399
	#>
	chomp $line;
	if ($line=~/^>/ and @arr!=0) {
		$i++;
		open OUT,">$out/$i.fa" or die "Can't open $out/$i.fa: $!\n";
		print INFO "$i.fa";
		my $all=@arr;
		my $content="\t$all\t";
		foreach my $item (@arr) {
			print OUT ">$item\n$hash{$item}";
			$content.="$item,";
			delete $hash{$item};
		}
		print INFO "$content\n";
		close OUT;
		%print=();
	}else {
			my ($Bname,$Qname)=(split /\s+/,$line)[0,1];
			$print{$Bname}=1;
			$print{$Qname}=1;
			@arr=keys %print;
			$all{$Bname}=1;
			$all{$Qname}=1;
	}
}
close IN;
my @al=keys %all;
my $m=@al;
print "group: $m\n";

my @b=keys %hash;
my $filtered=@b;
print "filtered: $filtered\n";

my $filteredinfo="";
open OUT,">$out/filtered.fa" or die "Can't open $out/filtered.fa: $!\n";
while ( my ($key, $value) = each %hash ) {
	print OUT ">$key\n$value";
	$filteredinfo.="$key,";
}
print INFO "filtered.fa\t$filtered\t$filteredinfo\n";
close OUT;
close INFO;

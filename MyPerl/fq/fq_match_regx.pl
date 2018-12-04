#!/usr/bin/perl
#CGTAAC GATAATTTATTGTCT GACGCTCTTCCGATCT CCGGTGGAGAAGAAGGACGAAACACCTTTTGGGGTGAGATAGGAAGTAGAAGCTTGTG ATCACCGACTGCCCATAGAGAGGCTGAGACTGCCAAGGCACACAGGGATAGG
#CGTAAC GATAATTTATTGTCT GACGCTCTTCCGATCT CCGGTGGAGAAGAAGGACGAAACACCTTTTGGGGTGAGATAGGAAGTAGAAGCTTGTG ATCACCGA

#*********************************************************************************
# FileName: fq_match_regx.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-8-23
# Description: This code is to split fastq file based on given barcode file,
#              adaptor and tail seq.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;
use Getopt::Long;
use Cwd 'abs_path';

my ($in,$out,$barcode,$adaptor,$tail);
GetOptions(
	"help|?"   =>\&USAGE,
	"i=s"     =>\$in,
	"o=s"      =>\$out,
	"bar=s"     =>\$barcode,
	"ad=s"     =>\$adaptor,
	"tail=s"   =>\$tail,
);

unless ($in and $out and $barcode and $adaptor and $tail) {
	&USAGE;
}
my $part_tail=substr ($tail,0,8);

#my $barcode="CGTAAC";
#my $adaptor="GACGCTCTTCCGATCT";
#my $tail="ATCACCGACTGCCCATAGAGAGGCTGAGACTGCCAAGGCACACAGGGATAGG";
#my $part_tail="ATCACCGA";

unless (-d $out) {
	mkdir $out;
}
$in=abs_path($in);
$out=abs_path($out);
$barcode=abs_path($barcode);

my (%bar,$barlen);
open (BC, "$barcode") or die "Cannot open $barcode: $!\n";
while (my $line=<BC>) {
	#CGTAAC
	chomp $line;
	if (exists $bar{$line}) {
		die "Error: $line has repetition\n";
	}
	$bar{$line}=length $line;
	$barlen=length $line;
}
close BC;

while (my ($key,$value)=each %bar) {
	if ($value!=$barlen) {
		die "Error: the length of $key, $value, is not equal to $barlen\n";
	}
	if (-d "$out/bar_$key") {
		system "rm -fr $out/bar_$key";
		mkdir "$out/bar_$key";
		mkdir "$out/bar_$key/mt_all";
	}else {
		mkdir "$out/bar_$key";
		mkdir "$out/bar_$key/mt_all";
	}
}

open (IN, "$in") or die "Cannot open $in: $!\n";
my $n=1;
my ($name,$seq,$plus,$qual,$raw_reads,%mt_reads,%hash);
while (my $line=<IN>) {
	#@MN00129:3:000H22KYJ:1:11101:14202:1055 1:N:0:1
	#AACTCCTACGGAAGGCAGCAGTGATAAACCTTTAGCAATAAACCAAAGTTTAACTAAGCCATACTAACCCCAGGGTTGGTCAATTTCGTGCCAGCCACCGCGGTCACACGATTAACCCAAGTCAATAGAAACCGGCATAAAGAGTGTTTTAGATCAATTCCCCTCAATAAAGCTAAAATTCACGTGAGTTGTAAAAAACTCCAGTTGATACAAAATAAACTACGAAAGTGGCTTTAATGCATCT
	#+
	#AAAFFFFCGC?GE?2AEFGHHFHGHHGHHHHHHHHHHHHHGHHHEHEHHHHFHHHGBFHGHHGHHGHHHHGGGGF2?@EEHHGHHHHHHEGGHEFGHHHEEGGA/EFFH?EGHGGHHHGEHHHHFHFDFHHGA<@CGDFHBFGGFHFGFFGCGGGBGHHHHHHGG.GHHHBDHHHGFHGHHHGFGEEGHGFFF0C:0BGGEFFGGFGBCBFF09.BF0;BF0/9E.AA/9/A.FBB99B//;BF
	chomp $line;
	if ($n%4==1) {
		$name=$line;
		if ($name!~/^\@/) {
			die "FQ format error at line $n\n";
		}
	}elsif ($n%4==2) {
		$seq=$line;
	}elsif ($n%4==3) {
		$plus=$line;
		if ($line!~/^\+/) {
			die "FQ format error at line $n\n";
		}
	}elsif ($n%4==0) {
		$raw_reads++;
		$qual=$line;
		if ($seq=~/[^ATGCatgc]/) {
				$n++;
				next;
		}
		if ($seq=~/^(.{$barlen})([ATGC]{15})$adaptor(.*)$/) {
			my $barseq=$1;
			unless (exists $bar{$barseq}) {
				$n++;
				next;
			}
			my $mt=$2;
			my $read_tl=$3;
			my ($read,$tl,$cuttl,$readqual);
			my $cutbc=$barlen;
			my $cutmt=length $mt;
			my $cutad=length $adaptor;
			if ($read_tl=~/^(.*)($part_tail.*)$/) {
				$read=$1;
				$tl=$2;
				$cuttl=length $tl;
				$qual=~/^(.{$cutbc})(.{$cutmt})(.{$cutad})(.*)(.{$cuttl})$/;
				$readqual=$4;
			}else {
				$read=$read_tl;
				$qual=~/^(.{$cutbc})(.{$cutmt})(.{$cutad})(.*)$/;
				$readqual=$4;
			}
			my $readlen=length $read;
			if ($readlen<50) {
				$n++;
				next;
			}
			open (MT, ">>$out/bar_$barseq/mt_all/$barseq\_$mt.fq")
				or die "Cannot write $out/bar_$barseq/mt_all/$barseq\_$mt.fq: $!\n";
			print MT "$name\n$read\n$plus\n$readqual\n";
			close MT;
			$mt_reads{$barseq}++;
			$hash{$barseq}{$mt}++;
		}
	}
	$n++;
}
close IN;

open (INFO, ">$out/data.split.info")
	or die "Cannot write $out/data.split.info: $!\n";
print INFO "raw_reads: $raw_reads\n\n";
foreach my $key1 (keys %hash) {
	my $bar_read=0;
	my $mt_sum=0;
	my %count=();
	open (LIS, ">$out/bar_$key1/$key1\_5fq.lis")
		or die "Cannot write $out/$key1\_5fq.lis: $!\n";
	foreach my $key2 (keys $hash{$key1}) {
		$bar_read+=$hash{$key1}{$key2};
		$mt_sum++;
		my $occur=$hash{$key1}{$key2};
		$count{$occur}++;
		if ($hash{$key1}{$key2}<5) {
			system "rm -f $out/bar_$key1/mt_all/$key1\_$key2.fq";
		}else {
			print LIS "$out/bar_$key1/mt_all/$key1\_$key2.fq\t$hash{$key1}{$key2}\n";
		}
	}
	close LIS;
	print INFO "bar_${key1}_read: $bar_read\n";
	print INFO "bar_${key1}_mt: $mt_sum\n";
	foreach my $i (1..10) {
		print INFO "\t$i==>$count{$i}\n";
	}
}
close INFO;

#************************************************************************************
# Function Name: USAGE
# Description: This function is to print $usage.
# Parameters:
#    Null
# Return:
#    The $usage is returned.
#************************************************************************************
sub USAGE{
	my $usage = <<"USAGE";
	usage : perl $0  -i sample.fq -o outputdir -bar barcode -ad adaptor -tail tailseq
			-help  help
			-i      <str>  sample.fq
			-o      <str>  outputdir
			-bar    <str>  barcode
			-ad     <str>  adaptor
			-tail   <str>  tailseq
USAGE
	print $usage;
	exit;
}

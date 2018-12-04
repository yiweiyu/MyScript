#!/usr/bin/perl

#*********************************************************************************
# FileName: fuse_db.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-7-7
# Description: This code is generate fusion db.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	$0 <siteinfo> <gene1_left> <gene1_right> <gene2_left> <gene2_right> <out>
USAGE

if (@ARGV!=6) {
	die $usage;
}
my $siteinfo=shift;
my $gene1_left=shift;
my $gene1_right=shift;
my $gene2_left=shift;
my $gene2_right=shift;
my $out=shift;

$/=">";
my %hash;
open (IN, "$gene1_left") or die "Can not open $gene1_left: $!\n";
<IN>;
while (my $line=<IN>) {
	#>TPR|exon15|chr1_186325117_186325417
	#ACAGTATTTTCCCATTAGTCTAAACAGCTAAGGTTTTACTATGTCAACAC
	#TAATGATTTCAGCTTAGTATCAGTTGTTAGTTATCTATTACCAGATAATC
	my ($name,$seq)=(split /\n/,$line,2)[0,1];
	chomp $seq;
	$hash{$name}=$seq;
}
close IN;

open (IN, "$gene2_left") or die "Can not open $gene2_left: $!\n";
<IN>;
while (my $line=<IN>) {
	#>TPR|exon15|chr1_186325117_186325417
	#ACAGTATTTTCCCATTAGTCTAAACAGCTAAGGTTTTACTATGTCAACAC
	#TAATGATTTCAGCTTAGTATCAGTTGTTAGTTATCTATTACCAGATAATC
	my ($name,$seq)=(split /\n/,$line,2)[0,1];
	chomp $seq;
	$hash{$name}=$seq;
}
close IN;

open (IN, "$gene1_right") or die "Can not open $gene1_right: $!\n";
<IN>;
while (my $line=<IN>) {
	#>TPR|exon15|chr1_186325117_186325417
	#ACAGTATTTTCCCATTAGTCTAAACAGCTAAGGTTTTACTATGTCAACAC
	#TAATGATTTCAGCTTAGTATCAGTTGTTAGTTATCTATTACCAGATAATC
	my ($name,$seq)=(split /\n/,$line,2)[0,1];
	chomp $seq;
	$hash{$name}=$seq;
}
close IN;

open (IN, "$gene2_right") or die "Can not open $gene2_right: $!\n";
<IN>;
while (my $line=<IN>) {
	#>TPR|exon15|chr1_186325117_186325417
	#ACAGTATTTTCCCATTAGTCTAAACAGCTAAGGTTTTACTATGTCAACAC
	#TAATGATTTCAGCTTAGTATCAGTTGTTAGTTATCTATTACCAGATAATC
	my ($name,$seq)=(split /\n/,$line,2)[0,1];
	chomp $seq;
	$hash{$name}=$seq;
}
close IN;

$/="\n";

my $id=0;
open IN, "$siteinfo" or die "Can't open '$siteinfo': $!";
open OUT,">$out" or die "Can't open '$out': $!";
open OUT1,">$out.info" or die "Can't open '$out.info': $!";
while (my $line=<IN>) {
	chomp $line;
	#TPR     chr1    186325417       15      ALK     chr2    29446394        20
	#BIM     chr2    111883195               BIM     chr2    111886091
	my @temp=split/\t/,$line;
	my ($name1,$chr1,$medium1,$exon1)=@temp[0,1,2,3];
	my ($name2,$chr2,$medium2,$exon2)=@temp[4,5,6,7];
	my $left=0;
	my $right=0;
	my ($token1_left,$token1_right);
	$left=$medium1-300;
	$right=$medium1+300;
	if ($exon1) {
		$token1_left="$name1|exon$exon1|$chr1"."_$left"."_$medium1";
		$token1_right="$name1|exon$exon1|$chr1"."_$medium1"."_$right";
	}else {
		$token1_left="$name1|$chr1"."_$left"."_$medium1";
		$token1_right="$name1|$chr1"."_$medium1"."_$right";
	}
	my ($token2_left,$token2_right);
	$left=$medium2-300;
	$right=$medium2+300;
	if ($exon2) {
		$token2_left="$name2|exon$exon2|$chr2"."_$left"."_$medium2";
		$token2_right="$name2|exon$exon2|$chr2"."_$medium2"."_$right";
	}else {
		$token2_left="$name2|$chr2"."_$left"."_$medium2";
		$token2_right="$name2|$chr2"."_$medium2"."_$right";
	}
	if (exists $hash{$token1_left} and exists $hash{$token1_right}) {
		if (exists $hash{$token2_left} and exists $hash{$token2_right}) {
			print OUT1 ">$token1_left\n$hash{$token1_left}>$token1_right\n$hash{$token1_right}";
			print OUT1 ">$token2_left\n$hash{$token2_left}>$token2_right\n$hash{$token2_right}";
			my ($name,$seq,$r_seq);
			$id++;
			$name=">FusionID$id $token1_left-1L2R-$token2_right";
			$seq=$hash{$token1_left}.$hash{$token2_right};
			$seq=~s/\s+//g;
			$seq=~s/(.{50})/$1\n/g;
			print OUT "$name\n$seq\n";

			$id++;
			$name=">FusionID$id $token2_left-2L1R-$token1_right";
			$seq=$hash{$token2_left}.$hash{$token1_right};
			$seq=~s/\s+//g;
			$seq=~s/(.{50})/$1\n/g;
			print OUT "$name\n$seq\n";

			$id++;
			$name=">FusionID$id $token1_left-1L2l-$token2_left";
			$r_seq=$hash{$token2_left};
			$r_seq=~tr/ACGTacgt/TGCAtgca/;
			$r_seq=reverse $r_seq;
			$seq=$hash{$token1_left}.$r_seq;
			$seq=~s/\s+//g;
			$seq=~s/(.{50})/$1\n/g;
			print OUT "$name\n$seq\n";

			$id++;
			$name=">FusionID$id $token1_right-1r2R-$token2_right";
			$r_seq=$hash{$token1_right};
			$r_seq=~tr/ACGTacgt/TGCAtgca/;
			$r_seq=reverse $r_seq;
			$seq=$r_seq.$hash{$token2_right};
			$seq=~s/\s+//g;
			$seq=~s/(.{50})/$1\n/g;
			print OUT "$name\n$seq\n";
		}else {
			print "warning: $line\n";
		}
	}else {
		print "warning: $line\n";
	}
}
close IN;
close OUT;



#! /usr/bin/perl

#****************************************************************************************
# FileName: fastq_quality.pl
# Description: This code is the pipeline of Rocky_BC.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0
# ModifyList:
#    Revision: V1.1
#    Modifier: Zhang Shehuan <zhangshehuan@celloud.cn>
#    ModifyTime: 2018-05-15
#    ModifyReason: add file size and AVG.Q, allow SE;
#                  Automatic judgment of the quality value system Phred33 and Phred 64
#****************************************************************************************
use strict;
use warnings;
use Data::Dumper;
use File::Basename qw(basename dirname);
use Cwd qw(abs_path);
use Getopt::Long;
use FindBin qw($Bin);
use lib "$Bin/../pm";

use read_config;
use sub_time;
use openAll;

my $usage=<<USAGE;
	Usage: perl $0 <-f forward_fq> <-r reverse_fq> <-o out>
USAGE

my ($help,$forward,$reverse,$out);
$help=0;
GetOptions(
	"f:s"=>\$forward,
	"r:s"=>\$reverse,
	"o:s"=>\$out,
	"h!"=>\$help
);
$out||=".";
#if ($help==1 or defined($forward)==0 or defined ($reverse)==0 or defined ($out)==0) {
if ($help==1 or defined($forward)==0 or defined ($out)==0) {
	die $usage;
}

my $start_time=sub_time(localtime(time()));
print "<------------$start_time QC_info started running $0---------------->\n";

open OUT,">$out";
my $header="Sample\tTotal Reads\tTotal base\tfile size\tAverage length\t"
			."GC\tQ20\tQ30\tAVG.Q\n";
print OUT $header;
$forward=abs_path $forward;
&statsFastq($forward);
if (defined $reverse) {
	$reverse=abs_path $reverse;
	&statsFastq($reverse);
}
close OUT;
my $end_time=sub_time(localtime(time()));
print "<------------$end_time QC_info finished running $0---------------->\n";

sub statsFastq{
	my $filename=shift;
	print "$filename\n";
	my $size_info=`ls -lh $filename`;
	my $size=(split/\s+/,$size_info)[4];
	my ($m,$want,$Q,$n,$total_reads,$total_base,$total_qual,$num_GC,$num_30,$num_20);
	my ($percent_GC,$percent_30,$percent_20,$average_lenth,$average_qual);
	my $basename=basename $filename;
	my $content=openAll($filename);
	while (<$content>) {
		chomp;
		$m++;
		if ($m%4==0) {
			$want.=$_;
			if ($m>1) {
				my @temp=(split //,$want);
				my @temp_sort=sort { $a cmp $b } @temp;
				my $min=ord ($temp_sort[0]);
				my $max=ord ($temp_sort[-1]);
				print "$max $min ";
				if ($max<=73 && $min<59) {
					$Q=33;
					print "Phred+33\n";
				}elsif ($max>73 && $min>=64) {
					$Q=64;
					print "Phred+64\n";
				}
				last;
			}
		}
	}
	while (<$content>) {
		chomp;
		$n++;
		if ($n%4==1) {
			if ($_!~/^\@/) {
				die "fastq format error: line $n\n";
			}
			$total_reads++;
		}elsif ($n%4==2) {
			my $seq=$_;
			$total_base+=length $seq;
			my $G=$seq=~tr/G/G/;
			my $C=$seq=~tr/C/C/;
			$num_GC+=$G+$C;
		}elsif ($n%4==3) {
			if ($_!~/^\+/) {
				die "fastq format error: line $n\n";
			}
		}elsif ($n%4==0) {
			my $quality=$_;
			my @temp=split//,$quality;
			foreach my $temp (@temp) {
				my $need=ord($temp)-$Q;
				if ($need>=30) {
					$num_30+=1;
				}
				if ($need>=20) {
					$num_20+=1;
				}
				$total_qual+=$need;
			}
		}
	}
	$average_lenth=sprintf "%d", $total_base/$total_reads;
	$percent_GC=sprintf "%0.2f", $num_GC/$total_base*100;
	$percent_20=sprintf "%0.2f", $num_20/$total_base*100;
	$percent_30=sprintf "%0.2f", $num_30/$total_base*100;
	$average_qual=sprintf "%0.2f", $total_qual/$total_base;
	my $info="$basename\t$total_reads\t$total_base\t$size\t$average_lenth\t"
			."$percent_GC\t$percent_20\t$percent_30\t$average_qual\n";
	print OUT $info;
}

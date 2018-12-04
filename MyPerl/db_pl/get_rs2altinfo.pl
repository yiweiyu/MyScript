#!/usr/bin/perl

#*****************************************************************************
# FileName: get_rs2altinfo.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Description: This code is to add rs and exon info to brac db by ALLELEID.
# Create Time: 2018-07-24
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0
#*****************************************************************************
use strict;
use warnings;
use File::Basename qw(basename dirname);
use Encode;
use utf8;

if (@ARGV!=3) {
	die "\tUsage: $0 <rs> <clinvar_vcf> <out>\n";
}
my $rs=shift;
my $clinvar_vcf=shift;
my $out=shift;

my %hash;
open IN,"$rs" || die "Can't open '$rs': $!\n";
while (my $line=<IN>) {
	#sample	1092105	1092106	1092126	1092127	1092129	1092155	1092158	1092167	1092193	1092197	1092198	1092871	170083453	170083457	170083458
	#rs10056340	TT	TG	TT	TT	TT	TT	GG	TG	TT	TT	TT	TT	TT	TT	TT
	chomp $line;
	if ($line=~/^sample/ or $line=~/^$/) {
		next;
	}
	my $rsID=(split/\t/,$line)[0];
	$rsID=~s/^rs//;
	$hash{$rsID}=1;
}
close IN;


my %rs;
open VCF,"$clinvar_vcf" || die "Can't open '$clinvar_vcf': $!\n";
open OUT,">$out" or die "Can't open '$out': $!\n";
while (my $line=<VCF>) {
	##CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO
	#1       1014042 475283  G       A       .       .       ALLELEID=446939;CLNDISDB=MedGen:C4015293,OMIM:616126,Orphanet:ORPHA319563;CLNDN=Immunodeficiency_38_with_basal_ganglia_calcification;CLNHGVS=NC_000001.11:g.1014042G>A;CLNREVSTAT=criteria_provided,_single_submitter;CLNSIG=Benign;CLNVC=single_nucleotide_variant;CLNVCSO=SO:0001483;GENEINFO=ISG15:9636;MC=SO:0001583|missense_variant;ORIGIN=1;RS=143888043
	chomp $line;
	if ($line=~/^\#CHROM/) {
		print OUT "$line\n";
	}
	if ($line=~/^\#/ or $line=~/^$/) {
		next;
	}
	my @temp=split/\t/,$line;
	my ($chr,$pos,$ref,$alt,$info)=@temp[0,1,3,4,7];
	$chr="chr$chr";
	if ($info=~/RS=(\d+)/) {
		if (exists $hash{$1}) {
			print OUT "$line\n";
			delete $hash{$1};
		}
	}
}
close VCF;
close OUT;

open OUT,">$out.na" or die "Can't open '$out.na': $!\n";
my @rest=keys %hash;
my $rest_info=join "\n",@rest;
print OUT $rest_info;
close OUT;
#!/usr/bin/perl

#*****************************************************************************
# FileName: brac_hg19tohg38.append.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Description: This code is to convert snp_indel of hg19 to snp_indel of hg38.
# Create Time: 2018-07-05
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0
#*****************************************************************************
use strict;
use warnings;
use File::Basename qw(basename dirname);

if (@ARGV!=2) {
	die "\tUsage: $0 <in> <out>\n";
}
my $snp_indel=shift;
my $out_prefix=shift;

my (%ref_base,%alt_base,%mutation);
open IN,"$snp_indel" || die "Can't open '$snp_indel': $!\n";
open OUT,">$out_prefix\_hg38.xls" or die "Can't open '$out_prefix\_hg38.xls': $!\n";
while (my $line=<IN>) {
	#合并后还被标记为yes	name	type	entrez_name	variant_types	clinvar_entries	civic_actionability_score	variant_aliases	allele_registry_id	gene_id	evidence_items	sources	entrez_id	start	stop	chromosome	start2	stop2	chromosome2	reference_bases	variant_bases	ensembl_version	reference_build	representative_transcript	representative_transcript2	hgvs_expressions	description
	#1236	M1V	variant	BRCA1	start_lost;	54432;	0	RS80357287;MET1VAL;	CA001332	6	2868;		672	41276113	41276113	17				T	C	75	GRCh37	ENST00000471181.2		NM_007294.3:c.1A>G;NP_009225.1:p.Met1Val;NC_000017.10:g.41276113T>C;ENST00000471181.2:c.1A>G;	
	chomp $line;
	if ($line=~/entrez_name/ or $line=~/^$/) {
		print OUT "hg38_start\thg38_stop\thg38_chr\t$line\n";
		next;
	}
	if ($line=~/^$/) {
		next;
	}
	my ($start,$stop,$chr)=(split/\t/,$line)[13,14,15];
	if (defined $start and defined $stop) {
		if ($chr=~/17$/) {
			$start+=1847983;
			$stop+=1847983;
		}elsif ($chr=~/13$/) {
			$start-=574137;
			$stop-=574137;
		}
		print OUT "$start\t$stop\t$chr\t$line\n";
	}else {
		print OUT "\t\t\t$line\n";
	}
}
close IN;
close OUT;

#!/usr/bin/perl

#*****************************************************************************
# FileName: brac_hg19tohg38.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Description: This code is to convert snp_indel of hg19 to snp_indel of hg38.
# Create Time: 2018-05-25
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
	#Chr     Start   End     Ref     Alt     DP      AD      Freq    MuType  Gene    Accession       Exon    CDSMutation     AAMutation
	#chr17	41245587	41245587	T	-	35	3	8.57%	frameshift deletion	BRCA1	NM_007297	exon9	c.1820delA	p.K607fs
	#chr17	41226515	41226515	G	T	24	1	4.17%	stopgain	BRCA1	NM_007299	exon14	c.1196C>A	p.S399X
	#chr13	32914137	32914137	C	A	63	1	1.59%	stopgain	BRCA2	NM_000059	exon11	c.5645C>A	p.S1882X
	#chr13	32893291	32893291	G	T	30	1	3.33%	stopgain	BRCA2	NM_000059	exon3	c.145G>T	p.E49X
	chomp $line;
	if ($line=~/^(C|c)hr\s+/ or $line=~/^$/) {
		next;
	}
	my @a=split/\t/,$line;
	my $chr=shift @a;
	my $start=shift @a;
	my $stop=shift @a;
	#my $ref=shift @a;
	#my $alt=shift @a;
	if ($chr=~/17$/) {
		$start+=1847983;
		$stop+=1847983;
	}elsif ($chr=~/13$/) {
		$start-=574137;
		$stop-=574137;
	}
	print OUT "$chr\t$start\t$stop\t".(join "\t", @a)."\n";
}
close IN;
close OUT;

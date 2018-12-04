#!/usr/bin/perl

#*********************************************************************************
# FileName: name2sam.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-6-9
# Description: This code is to get sam record based on the given name and the input 
#              sam file.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*********************************************************************************

use strict;
use warnings;

if (@ARGV!=3) {
	die "	Usage: perl $0 <in_samfile> <in_name> <out>\n"
}
my $in=$ARGV[0];
my $name=$ARGV[1];
my $out=$ARGV[2];

my (%names,%rank);
open (NM, $name) or die "Can not open $name: $!\n";
while (my $line=<NM>) {
	#EML4:exon:12--NFIA:intron:9     chr2:42522563--chr1:61893137    51      MN00129:55:000H2K7FH:1:11108:14928:19731_R1,MN00129:55:000H2K7FH:1:11108:14928:19731_R2,MN00129:55:000H2K7FH:1:11108:15581:16620_R1,MN00129:55:000H2K7FH:1:11108:15581:16620_R2,MN00129:55:000H2K7FH:1:11109:18281:18326_R1,MN00129:55:000H2K7FH:1:11109:18281:18326_R2,MN00129:55:000H2K7FH:1:12101:1343:18531_R1,MN00129:55:000H2K7FH:1:12101:1343:18531_R2,MN00129:55:000H2K7FH:1:12105:21099:2800_R1,MN00129:55:000H2K7FH:1:12105:21099:2800_R2,MN00129:55:000H2K7FH:1:12107:12387:18802_R1,MN00129:55:000H2K7FH:1:12107:12387:18802_R2,MN00129:55:000H2K7FH:1:12108:10574:7507_R1,MN00129:55:000H2K7FH:1:12108:10574:7507_R2,MN00129:55:000H2K7FH:1:12108:1499:17759_R1,MN00129:55:000H2K7FH:1:12108:1499:17759_R2,MN00129:55:000H2K7FH:1:12109:25660:13860_R1,MN00129:55:000H2K7FH:1:12109:25660:13860_R2,MN00129:55:000H2K7FH:1:13103:14955:7936_R1,MN00129:55:000H2K7FH:1:13103:14955:7936_R2,MN00129:55:000H2K7FH:1:13107:6059:9129_R1,MN00129:55:000H2K7FH:1:13107:6059:9129_R2,MN00129:55:000H2K7FH:1:13107:7880:9617_R1,MN00129:55:000H2K7FH:1:13107:7880:9617_R2,MN00129:55:000H2K7FH:1:13109:4298:5223_R1,MN00129:55:000H2K7FH:1:13109:4298:5223_R2,MN00129:55:000H2K7FH:1:13110:26850:18674_R1,MN00129:55:000H2K7FH:1:13110:26850:18674_R2,MN00129:55:000H2K7FH:1:21104:7759:13507_R1,MN00129:55:000H2K7FH:1:21104:7759:13507_R2,MN00129:55:000H2K7FH:1:21107:17067:20379_R1,MN00129:55:000H2K7FH:1:21107:17067:20379_R2,MN00129:55:000H2K7FH:1:21109:4100:10880_R1,MN00129:55:000H2K7FH:1:21109:4100:10880_R2,MN00129:55:000H2K7FH:1:21110:12601:16645_R1,MN00129:55:000H2K7FH:1:21110:12601:16645_R2,MN00129:55:000H2K7FH:1:22101:8939:4898_R2,MN00129:55:000H2K7FH:1:22103:20899:19348_R1,MN00129:55:000H2K7FH:1:22103:20899:19348_R2,MN00129:55:000H2K7FH:1:22104:25092:3405_R1,MN00129:55:000H2K7FH:1:22104:25092:3405_R2,MN00129:55:000H2K7FH:1:23104:15596:10421_R1,MN00129:55:000H2K7FH:1:23104:15596:10421_R2,MN00129:55:000H2K7FH:1:23105:19477:11861_R1,MN00129:55:000H2K7FH:1:23105:19477:11861_R2,MN00129:55:000H2K7FH:1:23105:8617:14346_R1,MN00129:55:000H2K7FH:1:23105:8617:14346_R2,MN00129:55:000H2K7FH:1:23108:5623:10357_R1,MN00129:55:000H2K7FH:1:23108:5623:10357_R2,MN00129:55:000H2K7FH:1:23109:8630:19688_R1,MN00129:55:000H2K7FH:1:23109:8630:19688_R2
	chomp $line;
	my ($fusion_gene,$fusion_point,$fusion_reads_sum,$fusion_reads_info)=(split/\s+/,$line)[0,1,2,3];
	if ($fusion_reads_sum<5) {
		last;
	}
	my ($gene1_info,$gene2_info,)=(split /--/,$fusion_gene)[0,1];
	my $gene1=(split /:/,$gene1_info)[0];
	my $gene2=(split /:/,$gene2_info)[0];
	if ($gene1 eq $gene2) {
		next;
	}
	my @temp=split /,/,$fusion_reads_info;
	foreach my $i (@temp) {
		my $name_rmR12=$i;
		$name_rmR12=~s/_R(1|2)$//;
		$names{$name_rmR12}=$fusion_gene;
		$rank{$fusion_gene}=$fusion_reads_sum;
	}
}
close NM;

my %samInfo;
open (SAM, $in) or die "Can not open $in: $!\n";
open (OUT, ">$out") or die "Can not open $out\n";
while (my $line=<SAM>) {
	chomp $line;
	if ($line=~/^@/ | $line=~/^\s+$/) {
		next;
	}
	#E00509:81:HF7YCALXX:4:1101:15260:6056   0       chr1_120286478_120286652_PHGDH  1       42      43M     *       0       0       TGTGCCAACCAGGAGTTTCTTCTATTTCCAGGCCTCCTGGCAG     IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII     AS:i:0  XN:i:0  XM:i:0  XO:i:0  XG:i:0  NM:i:0  MD:Z:43 YT:Z:UU
	#E00509:81:HF7YCALXX:4:1101:20730:7198   0       chr19_55525684_55525851_GP6     1       24      51M     *       0       0       GTTTCACAGGCTGATCTTGTTTTTTAATGTGAAGGGAAGCGGGCAACGTGC     IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII     AS:i:-12        XN:i:0  XM:i:2  XO:i:0  XG:i:0  NM:i:2  MD:Z:3G19C27    YT:Z:UU
	my $temp=(split /\t/ , $line)[0];
	if (exists $names{$temp}) {
		my $fusion=$names{$temp};
		$samInfo{$fusion}.="$line\n";
		#print OUT "$names{$temp}\t$line\n";
	}
}
foreach my $key (sort {$rank{$b}<=>$rank{$a}} keys %rank) {
		print OUT "$key\t$rank{$key}\n$samInfo{$key}\n";
}
close SAM;
close OUT;

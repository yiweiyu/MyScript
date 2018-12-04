#! usr/bin/perl -w

#*****************************************************************************
# FileName: get_met.pl
# Description: This code is to calculate the average of methylation rates.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
# ModifyList:
#    Revision: V1.0.1
#    Modifier: Zhanshehuan
#    ModifyTime: 2017-8-1
#    ModifyReason: adjust the code format
#*****************************************************************************

use strict;
use warnings;

if (@ARGV!=1) {
	die "\tUsage: $0 <sam>\n";
}
my $sam=shift;
my $snp_1p19q=0;
open (S , $sam) or die $!;
while (my $line=<S>){
	chomp $line;
	if ($line=~/^@/) {
		next;
	}
	my $info=(split /\t/,$line)[5];
	if ($info=~/M/) {
		$snp_1p19q++;
	}
}
`echo "$snp_1p19q" >>"statistic.xls"`;
print "$snp_1p19q";

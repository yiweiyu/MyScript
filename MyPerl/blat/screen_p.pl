#!/usr/bin/perl

#*****************************************************************************
# FileName: screen_p.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-7-3
# Description: This code is to screen input based on given argument (the input 
#              is the output of Pblast.pl).
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 
					<in> <min_len> <min_iden>
					<min_Lratio> <max_Lratio>
					<max_start> <out>
USAGE
if (@ARGV!=7) {
	die $usage;
}
my $in=shift;
my $min_len=shift;
my $min_iden=shift;
my $min_Lratio=shift;
my $max_Lratio=shift;
my $max_start=shift;
my $out=shift;

my $blockname="";
my $i=0;
my $n=0;
open IN, "$in" or die "Can't open '$in': $!";
open OUT, ">$out" or die "Can't open '$out': $!";
#                    Query_name                     Sbjct_name  Query_len  Query_beg  Query_end  Sbjct_beg  Sbjct_end  Sbjct_len      Score     Expect   identity   Identity   positive   Positive      Frame
<IN>;
 while (my $line=<IN>) {
	#                      CelLoud2                   CelLoud23567        519          1        519        103        621        621       1029        0.0        100    519/519          0        0/0          0
	 chomp $line;
	my ($Qlen,$Query_beg,$Sbjct_beg,$Slen,$iden,$Iden)=(split/\s+/,$line)[3,4,6,8,11,12];
	if ($Qlen<$min_len or $Slen<$min_len or $iden<$min_iden) {
		next;
	}
	if ($Query_beg>$max_start and ($Qlen-$Query_beg)>$max_start) {
		next;
	}elsif ($Sbjct_beg>$max_start and ($Slen-$Sbjct_beg)>$max_start) {
		next;
	}
	my $real_len=(split/\//,$Iden)[-1];
	my $Qlen_ratio=$real_len*100/$Qlen;
	my $Slen_ratio=$real_len*100/$Slen;
	my $flag=0;
	if ($Qlen_ratio>=$max_Lratio and $Slen_ratio>=$min_Lratio) {
		$flag=1;
	}elsif ($Qlen_ratio>=$min_Lratio and $Slen_ratio>=$max_Lratio) {
		$flag=1;
	}

	if ($flag==0) {
		next;
	}else {
		print OUT "$line\n";
	}

}
close IN;
close OUT;

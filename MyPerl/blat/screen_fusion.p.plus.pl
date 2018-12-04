#!/usr/bin/perl

#*****************************************************************************
# FileName: screen_fusion.p.plus.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-7-13
# Description: This code is to screen input based on given argument (the input 
#              is the output of Pblast.pl).
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 
					<in> <min_iden> <min_lenratio> <out>
USAGE
if (@ARGV!=4) {
	die $usage;
}
my $in=shift;
my $min_iden=shift;
my $lenratio=shift;
my $out=shift;

open IN, "$in" or die "Can't open '$in': $!";
open OUT, ">$out" or die "Can't open '$out': $!";
#                    Query_name                     Sbjct_name  Query_len  Query_beg  Query_end  Sbjct_beg  Sbjct_end  Sbjct_len      Score     Expect   identity   Identity   positive   Positive      Frame
<IN>;
 while (my $line=<IN>) {
	#                      CelLoud2                   CelLoud23567        519          1        519        103        621        621       1029        0.0        100    519/519          0        0/0          0
	 chomp $line;
	my ($Query_len,$Sbjct_beg,$Sbjct_end,$iden,$Iden)=(split/\s+/,$line)[2,5,6,10,11];
	my $real_len=(split/\//,$Iden)[-1];
	my $ratio=$real_len*100/$Query_len;
	my $flag=1;
	if ($ratio<$lenratio) {
		$flag=0;
	}elsif ($iden<$min_iden) {
		$flag=0;
	}

	if ($flag==1) {
		my ($start,$stop);
		if ($Sbjct_beg<$Sbjct_end) {
			$start=$Sbjct_beg;
			$stop=$Sbjct_end;
		}else {
			$start=$Sbjct_end;
			$stop=$Sbjct_beg;
		}
		my $mark1=0;
		my $mark2=0;
		for (my $i=$start;$i<=$stop;$i++) {
			if ($i==301) {
				$mark1=1;
			}elsif ($i==302) {
				$mark2=1;
			}
			if ($mark1==1 and $mark2==1) {
				print OUT "$line\n";
				last;
			}
		}
	}else {
		next;
	}

}
close IN;
close OUT;

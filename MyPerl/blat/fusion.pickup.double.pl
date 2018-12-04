#!/usr/bin/perl

#*****************************************************************************
# FileName: fusion.pickup.double.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-7-14
# Description: This code is to screen input based on given argument (the input 
#              is the output of Pblast.pl).
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 
					<in> <out> <min_iden> <min_len> <max_len>
USAGE
if (@ARGV!=5) {
	die $usage;
}
my $in=shift;
my $out=shift;
my $min_iden=shift;
my $min_len=shift;
my $max_len=shift;

open IN, "$in" or die "Can't open '$in': $!";
open OUT, ">$out" or die "Can't open '$out': $!";
my $head=<IN>;
print OUT "$head";
my $cwq="";
my $cws="";
my $info="";
my $n=0;
while (my $line=<IN>) {
	#print "$line";
	#print "*$info*\n\n";
	my @temp=split/\s+/,$line;
	my $Query_name=$temp[0];
	my $Sbjct_name=$temp[1];
	my $identity=$temp[10];
	my $Identity=$temp[11];
	my $real_len=(split/\//,$Identity)[-1];
	if ($identity<$min_iden or $real_len<$min_len) {
		next;
	}

	if ($n==0) {
		$n++;
		$cwq=$Query_name;
		$cws=$Sbjct_name;
		$info.=$line;
	}else {
		if ($Query_name eq $cwq and $Sbjct_name eq $cws) {
			$info.=$line;
		}elsif ($Query_name eq $cwq and $Sbjct_name ne $cws) {
			#print "*$info*\n\n";
			my @w=split/\n/,$info;
			my @want=sort @w;
			my $position;
			my %matchlen=();
			my %pick=();
			my %Sbjct_pos=();
			foreach my $item (@want) {
				my @what=split/\s+/,$item;
				my $Query_beg=$what[3];
				my $Query_end=$what[4];
				my $Sbjct_beg=$what[5];
				my $Sbjct_end=$what[6];
				my $Identity=$what[11];
				my $real_len=(split/\//,$Identity)[-1];
				if ($Query_beg<$Query_end) {
					$position="$Query_beg-$Query_end";
				}else {
					$position="$Query_end-$Query_beg";
				}

				$matchlen{$position}=$real_len;
				$pick{$position}=$item;

				if ($Sbjct_beg<$Sbjct_end) {
					$Sbjct_pos{$position}="$Sbjct_beg-$Sbjct_end";
				}else {
					$Sbjct_pos{$position}="$Sbjct_end-$Sbjct_beg";
				}
			}

			my $left=0;
			my $right=0;
			my @sort=sort { $matchlen{$a} <=> $matchlen{$b} } keys %matchlen;
			my $big=pop @sort;
			if ($matchlen{$big}>=$max_len) {
				my ($bigstart,$bigend)=(split/-/,$big)[0,1];
				foreach my $item (@sort) {
					my $flag=0;
					my ($start,$end)=(split/-/,$item)[0,1];
					if ($start>=$bigend or $end<=$bigstart) {
						my ($Sbjct_beg,$Sbjct_end)=(split/-/,$Sbjct_pos{$item})[0,1];
						if ($Sbjct_beg<301 and $Sbjct_end<301) {
							$flag=1;
							$left=1;
						}elsif ($Sbjct_beg>=301 and $Sbjct_end>=301) {
							$flag=1;
							$right=1;
						}else{
							$flag=1;
							$left=1;
							$right=1;
						}
					}
					if ($flag==0) {
						delete $pick{$item};
					}
				}
				if ($left==1 and $right==1) {
					#print "$info";
					while (my ($key,$value)=each %pick) {
						if ($key eq $big) {
							next;
						}else {
							print OUT "$value\n";
						}
					}
					$pick{$big}=~s/\*$//;
					print OUT "$pick{$big}*\n";
				}
			}
			$info="";
			$info.=$line;
			$cws=$Sbjct_name;
			$info.=$line;
		}elsif ($Query_name ne $cwq) {
			#print "*$info*\n\n";
			my @w=split/\n/,$info;
			my @want=sort @w;
			my $position;
			my %matchlen=();
			my %pick=();
			my %Sbjct_pos=();
			foreach my $item (@want) {
				my @what=split/\s+/,$item;
				my $Query_beg=$what[3];
				my $Query_end=$what[4];
				my $Sbjct_beg=$what[5];
				my $Sbjct_end=$what[6];
				my $Identity=$what[11];
				my $real_len=(split/\//,$Identity)[-1];
				if ($Query_beg<$Query_end) {
					$position="$Query_beg-$Query_end";
				}else {
					$position="$Query_end-$Query_beg";
				}

				$matchlen{$position}=$real_len;
				$pick{$position}=$item;

				if ($Sbjct_beg<$Sbjct_end) {
					$Sbjct_pos{$position}="$Sbjct_beg-$Sbjct_end";
				}else {
					$Sbjct_pos{$position}="$Sbjct_end-$Sbjct_beg";
				}
			}

			my $left=0;
			my $right=0;
			my @sort=sort { $matchlen{$a} <=> $matchlen{$b} } keys %matchlen;
			my $big=pop @sort;
			if ($matchlen{$big}>=$max_len) {
				my ($bigstart,$bigend)=(split/-/,$big)[0,1];
				foreach my $item (@sort) {
					my $flag=0;
					my ($start,$end)=(split/-/,$item)[0,1];
					if ($start>=$bigend or $end<=$bigstart) {
						my ($Sbjct_beg,$Sbjct_end)=(split/-/,$Sbjct_pos{$item})[0,1];
						if ($Sbjct_beg<301 and $Sbjct_end<301) {
							$flag=1;
							$left=1;
						}elsif ($Sbjct_beg>=301 and $Sbjct_end>=301) {
							$flag=1;
							$right=1;
						}else{
							$flag=1;
							$left=1;
							$right=1;
						}
					}
					if ($flag==0) {
						delete $pick{$item};
					}
				}
				if ($left==1 and $right==1) {
					#print "$info";
					while (my ($key,$value)=each %pick) {
						if ($key eq $big) {
							next;
						}else {
							print OUT "$value\n";
						}
					}
					$pick{$big}=~s/\*$//;
					print OUT "$pick{$big}*\n";
				}
			}
			$info="";
			$info.=$line;
			$cwq=$Query_name;
			$cws=$Sbjct_name;
		}
	}
}
#print "*$info*\n\n";
my @w=split/\n/,$info;
my @want=sort @w;
my $position;
my %matchlen=();
my %pick=();
my %Sbjct_pos=();
foreach my $item (@want) {
	my @what=split/\s+/,$item;
	my $Query_beg=$what[3];
	my $Query_end=$what[4];
	my $Sbjct_beg=$what[5];
	my $Sbjct_end=$what[6];
	my $Identity=$what[11];
	my $real_len=(split/\//,$Identity)[-1];
	if ($Query_beg<$Query_end) {
		$position="$Query_beg-$Query_end";
	}else {
		$position="$Query_end-$Query_beg";
	}

	$matchlen{$position}=$real_len;
	$pick{$position}=$item;

	if ($Sbjct_beg<$Sbjct_end) {
		$Sbjct_pos{$position}="$Sbjct_beg-$Sbjct_end";
	}else {
		$Sbjct_pos{$position}="$Sbjct_end-$Sbjct_beg";
	}
}

my $left=0;
my $right=0;
my @sort=sort { $matchlen{$a} <=> $matchlen{$b} } keys %matchlen;
my $big=pop @sort;
if ($matchlen{$big}>=$max_len) {
	my ($bigstart,$bigend)=(split/-/,$big)[0,1];
	foreach my $item (@sort) {
		my $flag=0;
		my ($start,$end)=(split/-/,$item)[0,1];
		if ($start>=$bigend or $end<=$bigstart) {
			my ($Sbjct_beg,$Sbjct_end)=(split/-/,$Sbjct_pos{$item})[0,1];
			if ($Sbjct_beg<301 and $Sbjct_end<301) {
				$flag=1;
				$left=1;
			}elsif ($Sbjct_beg>=301 and $Sbjct_end>=301) {
				$flag=1;
				$right=1;
			}else{
				$flag=1;
				$left=1;
				$right=1;
			}
		}
		if ($flag==0) {
			delete $pick{$item};
		}
	}
	if ($left==1 and $right==1) {
		#print "$info";
		while (my ($key,$value)=each %pick) {
			if ($key eq $big) {
				next;
			}else {
				print OUT "$value\n";
			}
		}
		$pick{$big}=~s/\*$//;
		print OUT "$pick{$big}*\n";
	}
}


close IN;
close OUT;

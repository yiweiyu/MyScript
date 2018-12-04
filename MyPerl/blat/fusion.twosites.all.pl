#!/usr/bin/perl

#*****************************************************************************
# FileName: fusion.twosites.all.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-7-20
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
chomp $head;
print OUT "$head\tfusion\n";
my $cwq="";
my $cws="";
my $info="";
my $n=0;
my (%all,%filter,%fuse);
while (my $line=<IN>) {
	#print "$line";
	#print "*$info*\n\n";
	my @temp=split/\s+/,$line;
	my $Query_name=$temp[0];
	my $Sbjct_name=$temp[1];
	my $identity=$temp[10];
	my $Identity=$temp[11];
	$all{$Query_name}=1;
	my $real_len=(split/\//,$Identity)[-1];
	if ($identity<$min_iden or $real_len<$min_len) {
		$filter{$Query_name}=0;
		next;
	}

	if ($n==0) {
		$n++;
		$cwq=$Query_name;
		$cws=$Sbjct_name;
		$info.=$line;
		if (!exists$fuse{$cwq}) {
			$fuse{$cwq}=0;
		}
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

			my @sort=sort { $matchlen{$a} <=> $matchlen{$b} } keys %matchlen;
			my $big=$sort[-1];
			if ($matchlen{$big}>=$max_len) {
				my ($bigstart,$bigend)=(split/-/,$big)[0,1];
				my $flag1=0;
				my $flag2=0;
				foreach my $item (@sort) {
					my $good=0;
					my $mark1=0;
					my $mark2=0;
					my $mark3=0;
					my ($start,$end)=(split/-/,$item)[0,1];
					if ($start>=$bigend or $end<=$bigstart) {
						$good=1;
					}
					if ($good==0 and $item ne $big) {
						delete $pick{$item};
					}else {
						my ($Sbjct_beg,$Sbjct_end)=(split/-/,$Sbjct_pos{$item})[0,1];
						for (my $i=$Sbjct_beg;$i<=$Sbjct_end;$i++) {
							if ($i==301) {
								$mark1=1;
							}elsif ($i==302) {
								$mark2=1;
							}
							if ($mark1==1 and $mark2==1) {
								$mark3=1;
								last;
							}
						}
						if ($mark3==1) {
							$flag1=1;
							$flag2=1;
							my $left=int(301-$Sbjct_beg+1);
							my $right=int($Sbjct_end-302+1);
							if ($left<$right) {
								$pick{$item}.="\t$left";
							}else {
								$pick{$item}.="\t$right";
							}
						}elsif ($mark1==1) {
							$flag1=1;
							my $left=int(301-$Sbjct_beg+1);
							$pick{$item}.="\t1-$left";
						}elsif ($mark2==1) {
							$flag2=1;
							my $right=int($Sbjct_end-302+1);
							$pick{$item}.="\t2-$right";
						}else {
							$pick{$item}.="\t#";
						}
					}
				}
				if ($flag1==1 and $flag2==1) {
					#print "$info";
					$fuse{$cwq}=1;
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

			my @sort=sort { $matchlen{$a} <=> $matchlen{$b} } keys %matchlen;
			my $big=$sort[-1];
			if ($matchlen{$big}>=$max_len) {
				my ($bigstart,$bigend)=(split/-/,$big)[0,1];
				my $flag1=0;
				my $flag2=0;
				foreach my $item (@sort) {
					my $good=0;
					my $mark1=0;
					my $mark2=0;
					my $mark3=0;
					my ($start,$end)=(split/-/,$item)[0,1];
					if ($start>=$bigend or $end<=$bigstart) {
						$good=1;
					}
					if ($good==0 and $item ne $big) {
						delete $pick{$item};
					}else {
						my ($Sbjct_beg,$Sbjct_end)=(split/-/,$Sbjct_pos{$item})[0,1];
						for (my $i=$Sbjct_beg;$i<=$Sbjct_end;$i++) {
							if ($i==301) {
								$mark1=1;
							}elsif ($i==302) {
								$mark2=1;
							}
							if ($mark1==1 and $mark2==1) {
								$mark3=1;
								last;
							}
						}
						if ($mark3==1) {
							$flag1=1;
							$flag2=1;
							my $left=int(301-$Sbjct_beg+1);
							my $right=int($Sbjct_end-302+1);
							if ($left<$right) {
								$pick{$item}.="\t$left";
							}else {
								$pick{$item}.="\t$right";
							}
						}elsif ($mark1==1) {
							$flag1=1;
							my $left=int(301-$Sbjct_beg+1);
							$pick{$item}.="\t1-$left";
						}elsif ($mark2==1) {
							$flag2=1;
							my $right=int($Sbjct_end-302+1);
							$pick{$item}.="\t2-$right";
						}else {
							$pick{$item}.="\t#";
						}
					}
				}
				if ($flag1==1 and $flag2==1) {
					#print "$info";
					$fuse{$cwq}=1;
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
			if (!exists$fuse{$cwq}) {
				$fuse{$cwq}=0;
			}
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

my @sort=sort { $matchlen{$a} <=> $matchlen{$b} } keys %matchlen;
my $big=$sort[-1];
if ($matchlen{$big}>=$max_len) {
	my ($bigstart,$bigend)=(split/-/,$big)[0,1];
	my $flag1=0;
	my $flag2=0;
	foreach my $item (@sort) {
		my $good=0;
		my $mark1=0;
		my $mark2=0;
		my $mark3=0;
		my ($start,$end)=(split/-/,$item)[0,1];
		if ($start>=$bigend or $end<=$bigstart) {
			$good=1;
		}
		if ($good==0 and $item ne $big) {
			delete $pick{$item};
		}else {
			my ($Sbjct_beg,$Sbjct_end)=(split/-/,$Sbjct_pos{$item})[0,1];
			for (my $i=$Sbjct_beg;$i<=$Sbjct_end;$i++) {
				if ($i==301) {
					$mark1=1;
				}elsif ($i==302) {
					$mark2=1;
				}
				if ($mark1==1 and $mark2==1) {
					$mark3=1;
					last;
				}
			}
			if ($mark3==1) {
				$flag1=1;
				$flag2=1;
				my $left=int(301-$Sbjct_beg+1);
				my $right=int($Sbjct_end-302+1);
				if ($left<$right) {
					$pick{$item}.="\t$left";
				}else {
					$pick{$item}.="\t$right";
				}
			}elsif ($mark1==1) {
				$flag1=1;
				my $left=int(301-$Sbjct_beg+1);
				$pick{$item}.="\t1-$left";
			}elsif ($mark2==1) {
				$flag2=1;
				my $right=int($Sbjct_end-302+1);
				$pick{$item}.="\t2-$right";
			}else {
				$pick{$item}.="\t#";
			}
		}
	}
	if ($flag1==1 and $flag2==1) {
		#print "$info";
		$fuse{$cwq}=1;
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

open OUT, ">$out.no" or die "Can't open '$out.no': $!";
my $s=0;
my $m=0;
while (my ($key,$value)=each %fuse) {
	if ($value==0) {
		print OUT "$key\n";
		$s++;
	}elsif ($value==1) {
		$m++;
	}
	if (exists $filter{$key}) {
		delete $filter{$key};
		#print "$key\n";
	}
}
my @al=keys %all;
my $a=@al;

my @filt=keys %filter;
my $f=@filt;
close OUT;

`echo "blast reads\t$a\nfilter reads\t$f" >>"stat.xls"`;
`echo "single reads\t$s\nmultiple reads\t$m\n" >>"stat.xls"`;


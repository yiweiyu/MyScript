#!/usr/bin/perl -w

#*****************************************************************************
# FileName: merge_exact_vague.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2018-01-30
# Description: This code is to merge fusion mt and merge DS.
# CopyRight: Copyright (c) CelLoud, All rights reserved.
# Revision: V1.0.0
#*****************************************************************************

use strict;
use warnings;

my $usage=<<USAGE;
	Usage: perl $0 
				<fusion_D> <fusion_S> <fusion_V>
				<plus_reads> <uniq> <out_prefix>
USAGE
if (@ARGV!=6) {
	die $usage;
}
my $fusion_D=shift;
my $fusion_S=shift;
my $fusion_V=shift;
my $plus_reads=shift;
my $uniq=shift;
my $out=shift;

system "date";

my (%fusion,%fusion_uniq,%fusion_reads);
open IN, $fusion_D or die "Can't open '$fusion_D': $!\n";
while (my $line=<IN>) {
	#site1   site2   fusion_sum      fusionD_num     fusionS_num     uniq_sum        uniqD_num       uniqS_num       fusion_reads    fusionD_reads   fusionS_reads   uniq_reads      uniqD_reads     uniqS_reads
	chomp $line;
	my ($site1,$site2,$f_reads_sum,$uniq_sum,$f_reads)=(split/\s+/,$line)[0,1,3,6,9];
	if ($line=~/^site/) {
		next;
	}
	my ($chr_pos1,$geneinfo1)=(split/\|/,$site1)[0,1];
	my ($chr1,$pos1)=(split/:/,$chr_pos1)[0,1];
	my ($chr_pos2,$geneinfo2)=(split/\|/,$site2)[0,1];
	my ($chr2,$pos2)=(split/:/,$chr_pos2)[0,1];
	my $may="";
	if (exists $fusion{"$geneinfo1-$geneinfo2"}) {
		$may="$geneinfo1-$geneinfo2";
	}elsif (exists $fusion{"$geneinfo2-$geneinfo1"}) {
		$may="$geneinfo2-$geneinfo1";
	}
	if (exists $fusion{$may}) {
		my $flag=0;
		foreach my $i (keys $fusion{$may}) {
			my ($pre_chr1,$pre_pos1,$pre_chr2,$pre_pos2)=(split/_/,$i)[0,1,2,3];
			if ($chr1 eq $chr2 and $pre_chr1 eq $pre_chr2) {
				if ($chr1 eq $pre_chr1) {
					my $lena1=abs ($pos1-$pre_pos1);
					my $lena2=abs ($pos2-$pre_pos2);
					my $lenb1=abs ($pos1-$pre_pos2);
					my $lenb2=abs ($pos2-$pre_pos1);
					if ($lena1<5 and $lena2<5) {
						$flag=1;
					}elsif ($lenb1<5 and $lenb2<5) {
						$flag=1;
					}
				}
			}elsif ($chr1 eq $pre_chr1 and $chr2 eq $pre_chr2) {
				my $len1=abs ($pos1-$pre_pos1);
				my $len2=abs ($pos2-$pre_pos2);
				if ($len1<5 and $len2<5) {
					$flag=1;
				}
			}elsif ($chr1 eq $pre_chr2 and $chr2 eq $pre_chr1) {
				my $len1=abs ($pos1-$pre_pos2);
				my $len2=abs ($pos2-$pre_pos1);
				if ($len1<5 and $len2<5) {
					$flag=1;
				}
			}
			if ($flag==1) {
				$fusion{$may}{$i}+=$f_reads_sum;
				$fusion_uniq{$may}{$i}+=$uniq_sum;
				$fusion_reads{$may}{$i}.=$f_reads;
				last;
			}
		}
		if ($flag==0) {
			$fusion{"$geneinfo1-$geneinfo2"}{"$chr1\_$pos1\_$chr2\_$pos2"}+=$f_reads_sum;
			$fusion_uniq{"$geneinfo1-$geneinfo2"}{"$chr1\_$pos1\_$chr2\_$pos2"}+=$uniq_sum;
			$fusion_reads{"$geneinfo1-$geneinfo2"}{"$chr1\_$pos1\_$chr2\_$pos2"}.=$f_reads;
		}
	}else {
		$fusion{"$geneinfo1-$geneinfo2"}{"$chr1\_$pos1\_$chr2\_$pos2"}+=$f_reads_sum;
		$fusion_uniq{"$geneinfo1-$geneinfo2"}{"$chr1\_$pos1\_$chr2\_$pos2"}+=$uniq_sum;
		$fusion_reads{"$geneinfo1-$geneinfo2"}{"$chr1\_$pos1\_$chr2\_$pos2"}.=$f_reads;
	}
}
close IN;
open IN, $fusion_S or die "Can't open '$fusion_S': $!\n";
while (my $line=<IN>) {
	#site1   site2   fusion_num      uniq_num        fusion_reads    uniq_reads
	chomp $line;
	my ($site1,$site2,$f_reads_sum,$uniq_sum,$f_reads)=(split/\s+/,$line)[0,1,2,3,4];
	if ($line=~/^site/) {
		next;
	}
	my ($chr_pos1,$geneinfo1)=(split/\|/,$site1)[0,1];
	my ($chr1,$pos1)=(split/:/,$chr_pos1)[0,1];
	my ($chr_pos2,$geneinfo2)=(split/\|/,$site2)[0,1];
	my ($chr2,$pos2)=(split/:/,$chr_pos2)[0,1];
	my $may="";
	if (exists $fusion{"$geneinfo1-$geneinfo2"}) {
		$may="$geneinfo1-$geneinfo2";
	}elsif (exists $fusion{"$geneinfo2-$geneinfo1"}) {
		$may="$geneinfo2-$geneinfo1";
	}
	if (exists $fusion{$may}) {
		my $flag=0;
		foreach my $i (keys $fusion{$may}) {
			my ($pre_chr1,$pre_pos1,$pre_chr2,$pre_pos2)=(split/_/,$i)[0,1,2,3];
			if ($chr1 eq $chr2 and $pre_chr1 eq $pre_chr2) {
				if ($chr1 eq $pre_chr1) {
					my $lena1=abs ($pos1-$pre_pos1);
					my $lena2=abs ($pos2-$pre_pos2);
					my $lenb1=abs ($pos1-$pre_pos2);
					my $lenb2=abs ($pos2-$pre_pos1);
					if ($lena1<5 and $lena2<5) {
						$flag=1;
					}elsif ($lenb1<5 and $lenb2<5) {
						$flag=1;
					}
				}
			}elsif ($chr1 eq $pre_chr1 and $chr2 eq $pre_chr2) {
				my $len1=abs ($pos1-$pre_pos1);
				my $len2=abs ($pos2-$pre_pos2);
				if ($len1<5 and $len2<5) {
					$flag=1;
				}
			}elsif ($chr1 eq $pre_chr2 and $chr2 eq $pre_chr1) {
				my $len1=abs ($pos1-$pre_pos2);
				my $len2=abs ($pos2-$pre_pos1);
				if ($len1<5 and $len2<5) {
					$flag=1;
				}
			}
			if ($flag==1) {
				$fusion{$may}{$i}+=$f_reads_sum;
				$fusion_uniq{$may}{$i}+=$uniq_sum;
				$fusion_reads{$may}{$i}.=$f_reads;
				last;
			}
		}
		if ($flag==0) {
			$fusion{"$geneinfo1-$geneinfo2"}{"$chr1\_$pos1\_$chr2\_$pos2"}+=$f_reads_sum;
			$fusion_uniq{"$geneinfo1-$geneinfo2"}{"$chr1\_$pos1\_$chr2\_$pos2"}+=$uniq_sum;
			$fusion_reads{"$geneinfo1-$geneinfo2"}{"$chr1\_$pos1\_$chr2\_$pos2"}.=$f_reads;
		}
	}else {
		$fusion{"$geneinfo1-$geneinfo2"}{"$chr1\_$pos1\_$chr2\_$pos2"}+=$f_reads_sum;
		$fusion_uniq{"$geneinfo1-$geneinfo2"}{"$chr1\_$pos1\_$chr2\_$pos2"}+=$uniq_sum;
		$fusion_reads{"$geneinfo1-$geneinfo2"}{"$chr1\_$pos1\_$chr2\_$pos2"}.=$f_reads;
	}
}
close IN;

my $head = "site1\tsite2\tuniq_sum\tfusion_reads_num\tfusion_mt_num\t"
			."fusion_reads\tfusion_mt_info\n";

open OUT,">","$out\_exact.xls"
	or die "Can't open '$out\_exact.xls': $!\n";
print OUT $head;
foreach my $key (keys %fusion) {
	foreach my $subkey (keys $fusion{$key}) {
		my $f_reads_sum=$fusion{$key}{$subkey};
		my $uniq_sum=$fusion_uniq{$key}{$subkey};
		if ($f_reads_sum<$plus_reads or $uniq_sum<$uniq) {
			next;
		}
		my $f_reads=$fusion_reads{$key}{$subkey};
		my ($geneinfo1,$geneinfo2)=(split/-/,$key)[0,1];
		my ($chr1,$pos1,$chr2,$pos2)=(split/_/,$subkey)[0,1,2,3];
		my @reads=split/,/,$f_reads;
		my (%fusion_mt,%fusion_ct,%names);
		foreach my $i (@reads) {
			my $mt=(split /:/,$i)[0];
			$fusion_mt{$mt}=1;
			$fusion_ct{$mt}++;
			#$i=~s/^.{12}://;
			$i=~s/_R[12].*$//;
			$names{$i}=1;
		}
		my @names_key=keys %names;
		my $names_info=join ",",@names_key;
		my @info=&merge(\%fusion_mt);
		my %merge=%{$info[0]};
		my @merge_key=sort keys %merge;
		my $want;
		foreach my $key (@merge_key) {
			my @temp=@{$merge{$key}};
			my @merge_ct;
			foreach my $i (@temp) {
				push @merge_ct,"$i:$fusion_ct{$i}";
			}
			$want.="(".(join ",",@merge_ct).");";
		}
		$want=~s/;$//;
		print OUT "$chr1:$pos1|$geneinfo1\t$chr2:$pos2|$geneinfo2\t$uniq_sum\t";
		print OUT "$f_reads_sum\t".(scalar @merge_key)."\t$names_info\t$want\n";
	}
}
close OUT;

open OUT,">","$out\_vague.xls"
	or die "Can't open '$out\_vague.xls': $!\n";
print OUT $head;
open IN, $fusion_V or die "Can't open '$fusion_V': $!\n";
while (my $line=<IN>) {
	#site1   site2   fusion_num      uniq_num        fusion_reads    uniq_reads
	if ($line=~/^site/) {
		next;
	}
	chomp $line;
	my ($site1,$site2,$f_reads_sum,$uniq_sum,$f_reads)=(split/\s+/,$line)[0,1,2,3,4];
	if ($f_reads_sum<$plus_reads or $uniq_sum<$uniq) {
		next;
	}
	my @reads=split/,/,$f_reads;
	my (%fusion_mt,%fusion_ct,%names);
	foreach my $i (@reads) {
		my $mt=(split /:/,$i)[0];
		$fusion_mt{$mt}=1;
		$fusion_ct{$mt}++;
		#$i=~s/^.{12}://;
		$i=~s/_R[12].*$//;
		$names{$i}=1;
	}
	my @names_key=keys %names;
	my $names_info=join ",",@names_key;
	my @info=&merge(\%fusion_mt);
	my %merge=%{$info[0]};
	my @merge_key=sort keys %merge;
	my $want;
	foreach my $key (@merge_key) {
		my @temp=@{$merge{$key}};
		my @merge_ct;
		foreach my $i (@temp) {
			push @merge_ct,"$i:$fusion_ct{$i}";
		}
		$want.="(".(join ",",@merge_ct).");";
	}
	$want=~s/;$//;
	print OUT "$site1\t$site2\t$uniq_sum\t$f_reads_sum\t".(scalar @merge_key);
	print OUT "\t$names_info\t$want\n";
}
close IN;
close OUT;
system "date";

sub merge {
	my ($hash)=@_;
	my %fusion_mt=%$hash;
	my %merge;
	my @mts=keys %fusion_mt;
	my $begin=pop @mts;
	push @{$merge{$begin}},$begin;
	delete $fusion_mt{$begin};
	my $n=1;
	while ($n) {
		my @temp_mts=keys %fusion_mt;
		if (@temp_mts==0) {
			last;
		}
		foreach my $item (@temp_mts) {
			my @arr1=split//,$item;
			my $flag=0;
			foreach my $entry (keys %merge) {
				my $count;
				my @temp=@{$merge{$entry}};
				compare: foreach my $e (@temp) {
					my @arr2=split//,$e;
					$count=0;
					foreach my $i (0..$#arr2) {
						if ($arr1[$i] ne $arr2[$i]) {
							$count++;
						}
						if ($count>2) {
							last compare;
						}
					}
				}
				if ($count>2) {
					next;
				}else {
					$flag=1;
					push @{$merge{$entry}},$item;
					delete $fusion_mt{$item};
				}
			}
			if ($flag==0) {
				push @{$merge{$item}},$item;
				delete $fusion_mt{$item};
			}
		}
	}
	return (\%merge);
}



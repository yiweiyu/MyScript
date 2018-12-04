#!/usr/bin/perl
use strict;
use warnings;
if (@ARGV!=2) {
	die "\tUsage: $0 <in> <out>\n";
}
my $indir=shift;
my $out=shift;

#system "echo -e \"sample\t$sample_name\n\" >$out";
my @arr=glob "$indir/batch*/*/*/result/*";
system "echo -e sample >$out.0";
system "awk '{print \$5}' $arr[1] >>$out.0";
my $n=0;
foreach my $i (sort @arr) {
	$n++;
	my ($mark,$mark_num);
	if ($i=~/XX-(.*)_R.\//) {
		$mark=$1;
		$mark_num=$1;
		$mark_num=~s/^18R//;
	}
	my $batch=(split/\//,$i)[-5];
	system "echo -e \"$mark\" >$out.$batch.$mark_num.$n";
	system "awk '{print \$6}' $i >>$out.$batch.$mark_num.$n";
}
foreach my $i (1..3) {
	system "paste $out.0 $out.batch$i* >$out\_batch$i.xls";
}
system "rm -f $out.*";
print "$n\n";

#!/usr/bin/perl
use strict;
use warnings;

if (@ARGV!=3) {
	die "	Usage: perl $0 <blat> <psl> <output>\n";
}
my $file1=$ARGV[0];
my $file2=$ARGV[1];
my $out=$ARGV[2];

open (IN1, "$file1") or die "Can not open $file1\n";
my %hash1;
while (my $line1=<IN1>) {
#                    Query_name                     Sbjct_name  Query_len  Query_beg  Query_end  Sbjct_beg  Sbjct_end  Sbjct_len      Score     Expect   identity   Identity   positive   Positive      Frame
#M50179:11:000000000-AV8BA:1:1101:15609:1331_1                   V2_forward_2        248         89        108          1         20         20       40.1      2e-07        100      20/20          0        0/0          0
	chomp($line1);
	my @temp1=split/\s+/,$line1;
	my $name1=$temp1[0];
	$hash1{$name1}=1;
}
close IN1;

open (IN2, "$file2") or die "Can not open $file2\n";
my %hash2;
#psLayout version 3
#
#match   mis-    rep.    N's     Q gap   Q gap   T gap   T gap   strand  Q               Q       Q       Q       T               T       T       T       block   blockSizes      qStarts  tStarts
#        match   match           count   bases   count   bases           name            size    start   end     name            size    start   end     count
#---------------------------------------------------------------------------------------------------------------------------------------------------------------
<IN2>;
<IN2>;
<IN2>;
<IN2>;
<IN2>;
while (my $line2=<IN2>) {
#20      0       0       0       0       0       0       0       +       M50179:11:000000000-AV8BA:1:1101:15609:1331_1   248     1       21      V1_forward      20      0       20      1       20,     1,      0,
	my @temp2=split/\s+/,$line2;
	my $name2=$temp2[9];
	$hash2{$name2}=2;
}
close IN2;

open (OUT1, ">$out.1") or die "Can not write $out.1\n";
foreach my $key (keys %hash1) {
	if (exists $hash2{$key}) {
		delete $hash2{$key};
	}else {
		print OUT1 "$key\n";
	}
}
close OUT1;

open (OUT2, ">$out.2") or die "Can not write $out.2\n";
foreach my $key (keys %hash2) {
	print OUT2 "$key\n";
}
close OUT2;

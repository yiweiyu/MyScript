#*****************************************************************************
# FileName: mpileup.common.site.pl
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-8-4
# Description: This code is to get the common chr site in given mpileup files.
# Revision: V1.0.0
#*****************************************************************************
use strict;
use warnings;

my $usage="\tUsage: $0 \n"
		."\t\t<the array of mpileup files>"
		." (the smaller the first file, the better)\n";
if (@ARGV==0) {
	die $usage;
	exit;
}

my @files=@ARGV;
my $sum=@files;
my $temp=shift @files;

open FH,"<","$temp" or die $!;
my %hash=();
while(<FH>){
	chomp;
	my ($chr,$site)=(split/\s+/,$_)[0,1];
	my $info=$chr." ".$site;
	$hash{$info}=1;
}
close FH;

foreach my $item (@files) {
	my %mark=();
	open IN,"<","$item" or die $!;
	while (<IN>) {
		chomp;
		my ($chr,$site)=(split/\s+/,$_)[0,1];
		my $info=$chr." ".$site;
		if (exists $mark{$info}) {
			next;
		}
		if (exists $hash{$info}) {
			$hash{$info}++;
			$mark{$info}=1;
		}
	}
	close IN;
}

open OUT,">","common.site" or die $!;
while (my ($key, $value)=each %hash) {
	if ($value==$sum) {
		print OUT "$key\n";
	}
}
close OUT;

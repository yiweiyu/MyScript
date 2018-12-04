#!/usr/bin/perl
use strict;
use warnings;
use File::Basename qw(basename dirname);

if (@ARGV!=2) {
        die "\tUsage: $0 <sample_path.lis> <out_dir>\n";
}
my $sample_path=shift;
my $outdir=shift;
my $result_dir="/share/data_for_oss/output/234/123/";
open IN, $sample_path or die "Can not open '$sample_path': $!\n";
while (my $line=<IN>) {
		#| CWBIO-20171216_N38121_S1_L001_R1.fastq.gz     | /ossfsdata/file/234/20171222/17122208015053.fastq.gz |
		if ($line=~/Sample/) {
		next;
		}
		chomp $line;
		$line=~s/\s+//g;
		my ($name,$path)=(split /\|/,$line)[1,2];
		$name=~s/_R1.fastq.gz$//;
		my $id=(split /\//,$path)[-1];
		$id=~s/.fastq.gz$//;
		my @data1=glob "$result_dir/$id/trimed/*fastq";
		my @data2=glob "$result_dir/$id/trim/*trimmed.fq";
		my @data=(@data1,@data2);
		foreach my $i (@data) {
			if ($i=~/R1.trimmed.fq$/) {
				print "cp $i $outdir/$name\_R1.fastq\n";
				system "cp $i $outdir/$name\_R1.fastq";
			}elsif ($i=~/R2.trimmed.fq$/) {
				print "cp $i $outdir/$name\_R2.fastq\n";
				system "cp $i $outdir/$name\_R2.fastq";
			}elsif ($i=~/$id.fastq$/) {
				print "cp $i $outdir/$name\_R1.fastq\n";
				system "cp $i $outdir/$name\_R1.fastq";
			}else {
				print "cp $i $outdir/$name\_R2.fastq\n";
				system "cp $i $outdir/$name\_R2.fastq";
			}
		}
}
close IN;

=cut
if (@ARGV!=2) {
        die "\tUsage: $0 <sample_path.lis> <out_dir>\n";
}
my $sample_path=shift;
my $outdir=shift;
open IN, $sample_path or die "Can not open '$sample_path': $!\n";
while (my $line=<IN>) {
        #Filename(Sample)        path
        #BA201804007109  /ossfsdata/output/253/118/18041908888848
        if ($line=~/Sample/) {
                next;
        }
        chomp $line;
        my ($name,$path)=(split /\s+/,$line)[0,1];
        system "cp $path/result/all.species $outdir/$name\_all.species";
}
close IN;

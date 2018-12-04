#**********************************************************************************
# FileName: trim.pm
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-03-29
# Description: trim low quality bases in read files according to given quality value;
#              print high quality reads in read files whose lengths are both bigger 
#              than 30 after trimming to output files;
#              return the number of high quality reads.
# Revision: V1.0.0
# ModifyList:
#    Revision: V1.0.2
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-7-26
#    ModifyReason: add sub help and openfile.pm
#    Revision: V1.0.1
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-4-7
#    ModifyReason: add log information
#**********************************************************************************

package trim;         # must
require Exporter;         # must

use log_info;             # must
use openfile;             # must
use autodie;              # must
use Try::Tiny;            # must

@ISA = Exporter;          # must
@EXPORT = qw(trim_cut);   #must


sub cut {
	my ($Q,$r1,$r2,$r1_cutted,$r2_cutted)=@_;
	log_info("0","trim_cut");
	my $in;
	try {
		open ERR, ">>", "LOG.stderr";
		$in=openfile($r1);
	}
	catch {
		print ERR "$_";
		log_info("444","trim_cut");
	};
	my ($want,@temp,$temp);
	my $wz=0;
	while (<$in>) {
		chomp;
		$wz++;
		if ($wz%4==0) {
			$want=$_;
			last;
		}
	}

	@temp=split //,$want;
	foreach $temp (@temp) {
		$temp=ord ($temp);
		if ($temp>=80) {
				$Q= chr( 64 + $Q );
				last;
		}elsif ($temp<=58) {
				$Q= chr( 33 + $Q );
				last;
		}
	}

	my ($in1,$in2);
	try {
		$in1=openfile($r1);
		$in2=openfile($r2);
		open OUT1, ">", "$r1_cutted";
		open OUT2, ">", "$r2_cutted";
	}
	catch {
		print ERR "$_";
		log_info("444","trim_cut");
	};


	my @read1s;
	my @read2s;
	my $H_quality_read=0;
	while (<$in1>) {
		$read1s[0]=$_;
		$read1s[1]=<$in1>;
		$read1s[2]=<$in1>;
		$read1s[3]=<$in1>;

		$read2s[0]=<$in2>;
		$read2s[1]=<$in2>;
		$read2s[2]=<$in2>;
		$read2s[3]=<$in2>;
		@fq1s=trim_qu($Q,@read1s);
		@fq2s=trim_qu($Q,@read2s);
		if (length $fq1s[1]>30 && length $fq2s[1] >30) {
				$H_quality_read+=2;
				print OUT1 @fq1s;
				print OUT2 @fq2s;
		}
	}

	close $in1;
	close $in2;
	close OUT1;
	close OUT2;


	if (defined $H_quality_read) {
		log_info("2","trim_cut");
	}else {
		print ERR "trim_cut error:\n";
		print ERR "\tat least one variable isn't defined in its return values!\n";
		log_info("444","trim_cut");
	}
	close ERR;
	return ($H_quality_read);

}

sub trim_qu {
	my ($Q,@reads) = @_;
	chomp( $reads[3] );
	chomp( $reads[1] );
	my @it = split //, $reads[3];
	my $i = 0;
	for ( $i = 0 ; $i < @it ; $i++ ) {
		if ($it[$i] lt $Q) {
			last;
		}
	}
	if ($i == 0) {
		$i = 1;
	}
	$reads[3]=substr( $reads[3], 0, $i ) ."\n";
	$reads[1]=substr( $reads[1], 0, $i ) ."\n";
	return (@reads);
}

sub help {
	my $help=<<USAGE;

NAME

trim - trim low quality bases in read files

SYNOPSIS

use FindBin qw(\$Bin);
use lib "\$Bin/../pm";
use trim;
trim::help();
my (\$H_qual_read)=trim::cut(\$quality_threshold,\$fqR1_dir,\$fqR2_dir,\$R1out_dir,\$R2out_dir);
print "\$H_qual_read\\n";

DESCRIPTION

This module is to trim low quality bases in read files according to given quality value,
print high quality reads in read files to output files whose lengths are both bigger 
than 30 after trimming, and return the number of high quality reads.

After the trimming, two more files -- time log and error log will be generated. 
They have names "LOG.txt" and "LOG.stderr" respectively.

If one log file already exists, the relative information will be appended to it.

USAGE

print $help;
}

1;

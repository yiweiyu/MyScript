#****************************************************************************
# FileName: decompression.pm
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-5-23
# Description: decompress input file(only one fq file is allowed at a time).
# Revision: V1.0.0
# ModifyList:
#    Revision: V1.0.1
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-7-7
#    ModifyReason: add sub help and modify annotation information
#****************************************************************************

package decompression;                 # must
require Exporter;                   # must

use log_info;                       # must
use File::Basename qw(basename);    # must

@ISA = Exporter;                    # must
@EXPORT = qw(decompression);           #must

sub decompression {
	log_info("0","decompression");
	my ($fq,$outdir)=@_;
	my $mark=0;
	my($fq_new,$filename);
	if ($fq=~/\.tar.gz$/) {
		$mark=1;
		$fq_new=basename $fq;
		$fq_new=~s/\.tar\.gz//;
		system "tar -zxvOf $fq > $outdir/$fq_new";
	}elsif ($fq=~/\.gz$/) {
		$mark=1;
		$fq_new= basename $fq;
		$fq_new=~s/\.gz//;
		system "gunzip -c $fq >$outdir/$fq_new";
	}

	if ($mark==0) {
		$filename=basename $fq;
		$filename="$outdir/".$filename;
	}else {
		$filename="$outdir/".$fq_new;
		$fq=$filename;
	}

	if (defined $fq and defined $filename) {
		log_info("2","decompression");
	}else {
		log_info("444","decompression");
	}
	return ($fq,$filename);
}

sub help {
	my $help=<<USAGE;

NAME

decompression - decompression for the input fq file, only one file is allowed at a time.

SYNOPSIS

use FindBin qw(\$Bin);
use lib "\$Bin/../pm";
use decompression;
decompression::help(); #Print this help information
my (\$fq_in,\$filenamein)=decompression(\$fqin,\$outdir);
print "\$fq_in\\n\$filenamein\\n";
#**************************************************************************************
# \$fqin is the directory of input fq file which needs decompression.
# \$outdir is the output directory where the decompressed fq file is expected to locate.
#
# If \$fqin isn't a compressed package, \$fq_in is the original fq directory i.e. \$fq1,
# and \$filenamein is a directory under \$outdir which does not exist but the downstream
# process may use as the prefix of its output. Otherwise both \$fq_1 and \$filename1 
# represent the directory of decompressed fq file.
#**************************************************************************************

DESCRIPTION

The main focus of the decompression.pm is to get two kinds of directories:
1. the directory of available fq file which isn't a compressed package;
2. the directory that the downstream process may use as the prefix of its output.

After the decompression, two more files -- time log and error log will be generated. 
They have names "LOG.txt" and "LOG.stderr" respectively.

If one log file already exists, the relative information will be appended to it.


USAGE

print $help;
}
1;

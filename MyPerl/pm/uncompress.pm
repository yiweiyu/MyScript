#*******************************************************************************
# FileName: uncompress.pm
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-03-29
# Description: uncompress input fq files(only two files are allowed at a time).
# Revision: V1.0.0
# ModifyList:
#    Revision: V1.0.1
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-7-7
#    ModifyReason: add sub help and modify annotation information
#*******************************************************************************

package uncompress;                 # must
require Exporter;                   # must

use File::Basename qw(basename);    # must

@ISA = Exporter;                    # must
@EXPORT = qw(uncompress);           #must

sub uncompress {
	my ($fq1,$fq2,$outdir)=@_;
	my $mark=0;
	my($fq1_new,$fq2_new,$filename1,$filename2);
	if ($fq1=~/\.tar.gz$/) {
		$mark=1;
		$fq1_new=basename $fq1;
		$fq1_new=~s/\.tar\.gz//;
		system "tar -zxvOf $fq1 > $outdir/$fq1_new";
	}elsif ($fq1=~/\.gz$/) {
		$mark=1;
		$fq1_new= basename $fq1;
		$fq1_new=~s/\.gz//;
		system "gunzip -c $fq1 >$outdir/$fq1_new";
	}

	if ($fq2=~/\.tar.gz$/) {
		$mark=1;
		$fq2_new=basename $fq2;
		$fq2_new=~s/\.tar\.gz//;
		system "tar -zxvOf $fq2 > $outdir/$fq2_new";
	}elsif ($fq2=~/\.gz$/) {
		$mark=1;
		$fq2_new=basename $fq2;
		$fq2_new=~s/\.gz//;
		system "gunzip -c $fq2 >$outdir/$fq2_new";
	}

	if ($mark==0) {
		$filename1=basename $fq1;
		$filename2=basename $fq2;
		$filename1="$outdir/".$filename1;
		$filename2="$outdir/".$filename2;
	}else {
		$filename1="$outdir/".$fq1_new;
		$filename2="$outdir/".$fq2_new;
		$fq1=$filename1;
		$fq2=$filename2;
	}
	return ($fq1,$fq2,$filename1,$filename2);
}

sub help {
	my $help=<<USAGE;

NAME

uncompress - uncompression for the input fq files, only two files are allowed at a time.

SYNOPSIS

use FindBin qw(\$Bin);
use lib "\$Bin/../pm";
use uncompress;
uncompress::help(); #Print this help information
my (\$fq_1,\$fq_2,\$filename1,\$filename2)=uncompress(\$fq1,\$fq2,\$outdir);
#************************************************************************************
# \$fq1 and \$fq2 are the directories of input fq files which need uncompression.
# \$outdir is the output directory where the decompressed fq files are expected to locate.
#
# If \$fq1 isn't a compressed package, \$fq_1 is the original fq directory i.e. \$fq1,
# and \$filename1 is a directory under \$outdir which does not exist but the downstream
# process may use as the prefix of its output. Otherwise both \$fq_1 and \$filename1 
# represent the directory of decompressed fq1 file.
# If \$fq2 isn't a compressed package, \$fq_2 is the original fq directory i.e. \$fq2,
# and \$filename2 is a directory under \$outdir which does not exist but the downstream
# process may use as the prefix of its output. Otherwise both \$fq_2 and \$filename2 
# represent the directory of decompressed fq2 file.
#************************************************************************************

DESCRIPTION

The main focus of the uncompress.pm is to get two kinds of directories:
1. the directory of available fq file which isn't a compressed package;
2. the directory that the downstream process may use as the prefix of its output.

USAGE

print $help;
}

1;

#*****************************************************************************
# FileName: MKDIR.pm
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-05-19
# Description: remove the old input directory and make a new input directory.
# Revision: V1.0.0
# ModifyList:
#    Revision: V1.0.1
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-7-7
#    ModifyReason: add sub help and modify annotation information
#*****************************************************************************

package MKDIR;          # must
require Exporter;       # must

@ISA = Exporter;        # must
@EXPORT = qw(MKDIR);    #must


sub MKDIR {
	my ($inpath)=@_;
	if (-d $inpath) {
		system "rm -fr $inpath";
		system "mkdir $inpath";
	}else {
		system "mkdir $inpath";
	}

}

sub help {
	my $help=<<USAGE;

NAME

MKDIR - make or remake the input directory.

SYNOPSIS

use FindBin qw(\$Bin);
use lib "\$Bin/../pm";
use MKDIR;
MKDIR::help(); #Print this help information
MKDIR(\$indir); #\$indir is the input directory

DESCRIPTION

What this module does is that if the input directory has already existed, it will
remove the old input directory and make a new input directory, otherwise it will
make the input directory.

USAGE

print $help;
}

1;

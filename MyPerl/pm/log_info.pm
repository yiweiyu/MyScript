#**************************************************************************
# FileName: log_info.pm
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-03-29
# Description: Print the corresponding log information to LOG.txt file under
#              Current Working Directory according to the input flag number.
# Revision: V1.0.0
# ModifyList:
#    Revision: V1.0.2
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-7-7
#    ModifyReason: add sub help and modify annotation information
#    Revision: V1.0.1
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-4-7
#    ModifyReason: add log information
#**************************************************************************

package log_info;    # must
require Exporter;       # must

use sub_time;       # must
use autodie;
use Try::Tiny;

@ISA = Exporter;                    # must
@EXPORT = qw(log_info);           #must


sub log_info {
	my $flog=shift;
	my $program=shift;
	try {
		open ERR, ">>","LOG.stderr";
		open OUT, ">>", "LOG.txt";
	}
	catch {
		print ERR "$_";
		exit;
	};
	my $Time= sub_time(localtime(time()));
	if ($flog==0) {
		print OUT "[$Time +0800]\ttask\t0\tstart\t$program\tDone.\n";
	}elsif ($flog==2) {
		print OUT "[$Time +0800]\ttask\t0\tend\t$program\tDone.\n";
	}else {
		print OUT "[$Time +0800]\ttask\t0\terror\t$program\t";
		print OUT "At least one $program in this section is in error.\n";
		close OUT;
		exit;
	}
	close OUT;
	close ERR;
}

sub help {
	my $help=<<USAGE;
NAME

log_info - log information (time information or error warning) of input command.

SYNOPSIS

use FindBin qw(\$Bin);
use lib "\$Bin/../pm";
use log_info;
log_info::help(); #Print this help information
log_info(\$flag,\$cmd);
#************************************************************************************
# \$cmd is the input command.
# \$flag is the input flag number:
#    0 means \$cmd just started running;
#    2 means \$cmd just finished running;
#    other numbers mean there is at least one error in the execution of \$cmd.
#************************************************************************************

DESCRIPTION

DESCRIPTION

"log_info" is a module that prints the corresponding log information (time information 
or error warning) to "LOG.txt" under Current Working Directory according to the input 
flag number.

Though "LOG.stderr" will be generated, normally this module has nothing to do with it.

If one log file already exists, the relative information will be appended to it.

USAGE

print $help;
}

1;

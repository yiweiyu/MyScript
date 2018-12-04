#********************************************************************************
# FileName: runcmd.pm
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-03-29
# Description: run command and print log information to log files.
# Revision: V1.0.0
# ModifyList:
#    Revision: V1.0.3
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-7-12
#    ModifyReason: add sub help and modify annotation information
#    Revision: V1.0.2
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-5-19
#    ModifyReason: add one more \n at the end of $cmd while printing to LOG.sh;
#                  change work.sh to LOG.sh.
#    Revision: V1.0.1
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-4-7
#    ModifyReason: add log information.
#********************************************************************************

package runcmd;    # must
require Exporter;       # must

use log_info;       # must
use autodie;
use Try::Tiny;

@ISA = Exporter;                    # must
@EXPORT = qw(runcmd);           #must

sub runcmd {
	my ($program,$cmd)=@_;
	try {
		open ERR, ">>", "LOG.stderr";
		open SH, ">>LOG.sh";
	}
	catch {
		print ERR "$_";
	};
	print SH "$cmd\n\n";
	log_info(0,$program);
	system($cmd) && log_info(1,$program);
	log_info(2,$program);
	close SH;
	close ERR;
}

sub help {
	my $help=<<USAGE;

NAME

runcmd - run command and print log information to log files

SYNOPSIS

use FindBin qw(\$Bin);
use lib "\$Bin/../pm";
use runcmd;
runcmd::help(); #Print this help information
runcmd(\$cmdname,\$cmd);
#\$cmd is the command
#\$cmdname is the name of \$cmd

DESCRIPTION

runcmd aims at running the given command and print log information to log files.
Before submission, a command log file, "LOG.sh", will be generated. After the 
command is finished, two more files -- time log and error log will be generated. 
They have names "LOG.txt" and "LOG.stderr" respectively.

If one log file already exists, the relative information will be appended to it.

USAGE

print $help;
}


1;

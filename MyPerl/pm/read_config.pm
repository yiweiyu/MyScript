#****************************************************************************
# FileName: read_config.pm
# Creator: Wang Zhen <wangzhen@celloud.cn>
# Create Time: 2017-03-28
# Description: grasp dirctories of Database, Software and Java.
# Revision: V1.0.0
# ModifyList:
#    Revision: V1.0.2
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-7-11
#    ModifyReason: add sub help, and modify the if statement of "defined"
#    Revision: V1.0.1
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-4-26
#    ModifyReason: read config file, then grasp the three directories
#****************************************************************************

package read_config;    # must
require Exporter;       # must

use log_info;           # must
use autodie;            # must
use Try::Tiny;          # must

@ISA = Exporter;        # must
@EXPORT = qw(read_config);   #must


sub read_config {
	my ($config_dir)=@_;
	my($Software_path,$Database_path,$Java_path);
	try {
		open ERR, ">>", "LOG.stderr";
		open IN, "$config_dir";
	}
	catch {
		print ERR "$_";
		log_info("444","config");
	};
	while (<IN>) {
		chomp;
		if ($_=~/^Software_path/) {
			$Software_path=(split/\=/,$_)[1];
		}elsif ($_=~/^Database_path/) {
			$Database_path=(split/\=/,$_)[1];
		}elsif ($_=~/^Java_path/) {
			$Java_path=(split/\=/,$_)[1];
		}
	}
	close IN;
	if (defined $Software_path and defined $Database_path and defined $Java_path) {
		return $Software_path,$Database_path,$Java_path;
	}else {
		print ERR "error of read_config at $config_dir: \n";
		print ERR "\tat least one variable isn't defined in its return values!\n";
		log_info("444","config");
	}
	close ERR;
}

sub help {
	my $help=<<USAGE;

NAME

read_config - read config file, and get the tree directories in the config file.

SYNOPSIS

use FindBin qw(\$Bin);
use lib "\$Bin/../pm";
use read_config;
read_config::help(); #Print this help information
my (\$Software_path,\$Database_path,\$Java_path)=read_config(\$configdir);
#\$configdir is the directory of the config file
print "\$Software_path\\n\$Database_path\\n\$Java_path\\n";


DESCRIPTION

This module mainly proposes a function for reading config file, then returns 
tree directories in the config file. They are Software_path, Database_path
and Java_path in turn.

If config file is right, normally this module has nothing to do with "LOG.stderr". 
Otherwise the error warning will be printed to "LOG.txt" and the error information 
will be printed to "LOG.stderr".

If one log file already exists, the relative information will be appended to it.


USAGE

print $help;
}

1;

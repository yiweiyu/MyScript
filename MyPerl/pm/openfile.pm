#*****************************************************************************
# FileName: openfile.pm
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-03-29
# Description: open the given file
# Revision: V1.0.0
# ModifyList:
#    Revision: V1.0.2
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-7-10
#    ModifyReason: add sub help, add if statement of *.tar.gz
#    Revision: V1.0.1
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-4-7
#    ModifyReason: add log information
#*****************************************************************************

package openfile;          # must
require Exporter;          # must

@ISA = Exporter;           # must
@EXPORT = qw(openfile);    #must


sub openfile {
	my $file=shift;
	my $file_h;
	if ($file=~/\.tar.gz$/) {
		open $file_h, "tar -zxvOf $file |" or die "$!\n";
	}elsif ($file=~/\.gz$/) {
		#open $file_h, "cat $file |gzip -d |" or die "$!\n";
		open $file_h, "gunzip -c $file |" or die "$!\n";
	}else {
		open $file_h, "$file" or die "$!\n";
	}
	return $file_h;
}

sub help {
	my $help=<<USAGE;

NAME

openfile - open the file whose filename is given, and associate it with FILEHANDLE.

SYNOPSIS

use FindBin qw(\$Bin);
use lib "\$Bin/../pm";
use openfile;
my \$content=openfile(\$filedir);
#\$filedir is the directory of the input file
#\$content is a filehandle, the return value of openfile.
while (<\$content>) {
	print "\$_";
}

DESCRIPTION

Open the file whose filename is given, and associate it with FILEHANDLE.
The file can be a compressed package, for instance, a tar package or a gz 
package.

USAGE

print $help;
}

1;

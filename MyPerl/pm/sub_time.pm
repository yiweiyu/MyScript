#**************************************************************************************
# FileName: sub_time.pm
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-03-29
# Description: Parameter is the return value of localtime in list context. A time 
#              string is returned, taking the format of 'yyyy-mm-dd hh:mm:ss'.
# Revision: V1.0.0
# ModifyList:
#    Revision: V1.0.2
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-7-12
#    ModifyReason: add sub help, modify the value of $mon ($mon plus 1 in sprintf line)
#    Revision: V1.0.1
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-4-7
#    ModifyReason: add log information
#**************************************************************************************

package sub_time;    # must
require Exporter;       # must

@ISA = Exporter;                    # must
@EXPORT = qw(sub_time);           #must


sub sub_time {
	my($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = @_;
	$wday = $yday = $isdst = 0;
	sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
}

sub help {
	my $help=<<USAGE;

NAME

sub_time - a subfunction of time

SYNOPSIS

use FindBin qw(\$Bin);
use lib "\$Bin/../pm";
use sub_time;
sub_time::help(); #Print this help information
my \$Time_Start = sub_time(localtime(time()));
my \$i=7777;
while (\$i) {
    for (my \$n=\$i;\$n>0;\$n++) {
        \$n-=2;
    }
    \$i--;
}
my \$Time_End= sub_time(localtime(time()));
print "Finished. Running from [\$Time_Start] to [\$Time_End]\\n";


DESCRIPTION

This module allows you to get a time string taking the format of 'yyyy-mm-dd hh:mm:ss'.
The parameter must be the return value of localtime in list context.

USAGE

print $help;
}

1;

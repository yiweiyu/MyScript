#*****************************************************************************
# FileName: fq2fa.pm
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-03-29
# Description: This code is to convert fastq file to fasta file.
# Revision: V1.0.0
# ModifyList:
#    Revision: V1.0.3
#    Modifier: Zhang Shehuan
#    ModifyTime: 2018-01-09
#    ModifyReason: print $name itself
#    Revision: V1.0.2
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-7-26
#    ModifyReason: add sub help and openfile.pm, modify the name of output fa seq
#    Revision: V1.0.1
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-4-7
#    ModifyReason: add log information
#*****************************************************************************

package fq2fa;          # must
require Exporter;       # must

use log_info;           # must
use openfile;           # must
use autodie;            # must
use Try::Tiny;          # must

@ISA = Exporter;        # must
@EXPORT = qw(fq2fa);    #must


sub fq2fa {
	my ($fq,$fa)=@_;
	my $in;
	log_info("0","fq2fa");
	try {
		open ERR, ">>", "LOG.stderr";
		$in=openfile($fq);
		open OUT, ">", "$fa";
	}
	catch {
		print ERR "$_";
		log_info("444","fq2fa");
	};

	my $n=1;
	my ($name,$seq,$plus,$qual,$s,$q);
	while (my $line=<$in>) {
	#@M04030:17:000000000-AU86A:1:1101:12696:1847_1
	#AACTCCTACGGAAGGCAGCAGTGATAAACCTTTAGCAATAAACCAAAGTTTAACTAAGCCATACTAACCCCAGGGTTGGTCAATTTCGTGCCAGCCACCGCGGTCACACGATTAACCCAAGTCAATAGAAACCGGCATAAAGAGTGTTTTAGATCAATTCCCCTCAATAAAGCTAAAATTCACGTGAGTTGTAAAAAACTCCAGTTGATACAAAATAAACTACGAAAGTGGCTTTAATGCATCT
	#+
	#AAAFFFFCGC?GE?2AEFGHHFHGHHGHHHHHHHHHHHHHGHHHEHEHHHHFHHHGBFHGHHGHHGHHHHGGGGF2?@EEHHGHHHHHHEGGHEFGHHHEEGGA/EFFH?EGHGGHHHGEHHHHFHFDFHHGA<@CGDFHBFGGFHFGFFGCGGGBGHHHHHHGG.GHHHBDHHHGFHGHHHGFGEEGHGFFF0C:0BGGEFFGGFGBCBFF09.BF0;BF0/9E.AA/9/A.FBB99B//;BF
		chomp $line;
		if ($n%4==1) {
			$name=$line;
			$name=~s/^@//;
			print OUT ">$name\n";
=cut
			my @temp=split/\s/,$name;
			my $flag;
			foreach my $item (@temp) {
				$flag.="$item;";
			}
			$flag=~s/;$//;
			print OUT ">$flag\n";
=cut
		}elsif ($n%4==2) {
			$seq=$line;
			print OUT "$seq\n";
		}
		$n++;
	}
	close $in;
	close OUT;


	if (-e $fa) {
		if ( -z $fa) {
			print ERR "warning\tfa_file is null!\n";
			log_info("444","fq2fa");
		}else {
		log_info("2","fq2fa");
		}
	}else {
		print ERR "fa_file does not exist!\n";
		log_info("444","fq2fa");
	}
	close ERR;

}

sub help {
	my $help=<<USAGE;

NAME

fq2fa.pm - a fq-to-fa converter.

SYNOPSIS

use FindBin qw(\$Bin);
use lib "\$Bin/../pm";
use fq2fa;
fq2fa::help(); #Print this help information
fq2fa(\$fq, \$fa);
#************************************************************************************
# \$fq is the directory of input fq file which needs converting.
# \$fa is the directory of output fa file.
#************************************************************************************

DESCRIPTION

This module is a converter tunning fq file into fa file.

After the conversion, two more files -- time log and error log will be generated. 
They have names "LOG.txt" and "LOG.stderr" respectively.

If one log file already exists, the relative information will be appended to it.

USAGE
print $help;
}

1;

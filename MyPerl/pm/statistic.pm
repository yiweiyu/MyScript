#******************************************************************
# FileName: statistic.pm
# Creator: Zhang Shehuan <zhangshehuan@celloud.cn>
# Create Time: 2017-03-29
# Description: read fastqc_data.txt, calculate $total_reads,
#              $average_quality and $average_GC, then return 
#              $total_reads, $average_quality and $average_GC.
# Revision: V1.0.0
# ModifyList:
#    Revision: V1.0.2
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-7-12
#    ModifyReason: add sub help and modify annotation information
#    Revision: V1.0.1
#    Modifier: Zhang Shehuan
#    ModifyTime: 2017-4-7
#    ModifyReason: add log information
#******************************************************************

package statistic;      # must
require Exporter;       # must

use log_info;           # must
use autodie;            # must
use Try::Tiny;          # must

@ISA = Exporter;        # must
@EXPORT = qw(statistic);    #must


sub statistic {
	my ($QC_dir)=@_;
	my @file=glob "$QC_dir/*/fastqc_data.txt";

	log_info("0","statistic");
	try {
		open ERR, ">>", "LOG.stderr";
		open IN0, "$file[0]";
		open IN1, "$file[1]";
	}
	catch {
		print ERR "$_";
		log_info("444","statistic");
	};

	my $mark=0;
	my $quality=0;
	my ($Total_sequence1,$read_length1,$GC1,$num,$mean,$start,$end);
	while (<IN0>) {
		chomp;
		if ($_=~/^Total Sequences/) {
			$Total_sequence1=(split/\s+/,$_)[2];
		}elsif ($_=~/^Sequence length/) {
			if ($_=~/-/) {
				$read_length1=(split/-/,$_)[1];
			}else {
				$read_length1=(split/\s+/,$_)[2];
			}
		}elsif ($_=~/^\%GC/) {
			$GC1=(split/\s+/,$_)[1];
		}elsif ($_=~/^>>Per base sequence quality/) {
			$mark=1;
		}elsif ($mark==1 && $_=~/^>>END_MODULE/) {
			last;
		}elsif ($mark==1 && $_!~/^>>Per base sequence quality/ && $_!~/^\#/) {
	##Base Mean Median Lower Quartile Upper Quartile 10th Percentile 90th Percentile
	#1       33.60495107658217       34.0    34.0    34.0    34.0    34.0
	#10-14   37.17046013375516       38.0    38.0    38.0    36.0    38.0
	#50-59   36.80527491890593       38.0    37.0    38.0    34.8    38.0
			($num,$mean)=(split/\s+/,$_)[0,1];
			if ($num=~/-/) {
				($start,$end)=(split/-/,$num)[0,1];
				$quality+=($end-$start+1)*$mean*$Total_sequence1;
			}else {
				$quality+=$mean*$Total_sequence1;
			}
		}
	}
	close IN0;

	$mark=0;
	my $GC2;
	while (<IN1>) {
		chomp;
		if ($_=~/^\%GC/) {
			$GC2=(split/\s+/,$_)[1];
		}elsif ($_=~/^>>Per base sequence quality/) {
			$mark=1;
		}elsif ($mark==1 && $_=~/^>>END_MODULE/) {
			last;
		}elsif ($mark==1 && $_!~/^>>Per base sequence quality/ && $_!~/^\#/) {
			##Base Mean Median Lower Quartile Upper Quartile 10th Percentile 90th Percentile
			#1       33.60495107658217       34.0    34.0    34.0    34.0    34.0
			#10-14   37.17046013375516       38.0    38.0    38.0    36.0    38.0
			#50-59   36.80527491890593       38.0    37.0    38.0    34.8    38.0
			($num,$mean)=(split/\s+/,$_)[0,1];
			if ($num=~/-/) {
				($start,$end)=(split/-/,$num)[0,1];
				$quality+=($end-$start+1)*$mean*$Total_sequence1;
			}else{
				$quality+=$mean*$Total_sequence1;
			}
		}
	}
	close IN1;

	my $total_reads=$Total_sequence1*2;
	my $average_quality=(sprintf "%0.1f",$quality/$total_reads/$read_length1);
	my $average_GC=(sprintf "%d%%",($GC1+$GC2)/2);

	if (defined $total_reads && defined $average_quality && defined $average_GC) {
		log_info("2","statistic");
	}else {
		print ERR "statistic error:\n";
		print ERR "\tat least one variable isn't defined in its return values!\n";
		log_info("444","statistic");
	}
	close ERR;
	return ($total_reads,$average_quality,$average_GC);

}

sub help {
	my $help=<<USAGE;

NAME

statistic - statistics of sequencing quality parameters

SYNOPSIS

use FindBin qw(\$Bin);
use lib "\$Bin/../pm";
use statistic;
statistic::help(); #Print this help information
my (\$total_reads,\$average_quality,\$average_GC)=statistic(\$QCdir);
#\$QCdir is the result directory of QC, "QC/*/fastqc_data.txt".
print "\$total_reads\\n\$average_quality\\n\$average_GC\\n";


DESCRIPTION

This module provides a "statistic" type of three sequencing quality parameters (total 
reads, average quality, and average GC) to work with QC reports(the reports of R1 and 
R2 of the same sample).

The input parameter of this module must be the result directory of QC. There are two 
sub directories under input directory, each of which has a file named fastqc_data.txt.

After the statistic, two more files -- time log and error log will be generated. 
They have names "LOG.txt" and "LOG.stderr" respectively.

If one log file already exists, the relative information will be appended to it.

USAGE

print $help;
}

1;

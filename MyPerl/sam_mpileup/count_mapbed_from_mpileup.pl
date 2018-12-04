use strict;
use warnings;
use Data::Dumper;
use File::Basename qw(basename dirname);
use Cwd qw(abs_path);
if (@ARGV!=2) {
	die "\tUsage: $0 <in> <out>\n";
}
my $in=shift;
my $out=shift;
my %hash;
open IN,"$in" || die "Can't open '$in': $!\n";
while (my $line=<IN>) {
	#chrMT   240     A       1       .       E
	chomp $line;
	my ($chr,$pos,$depth)=(split/\s+/,$line)[0,1,3];
	$hash{$chr}{$pos}=$depth;
}
close IN;

open ALL,">$out.all" || die "Can't open '$out.all': $!\n";
open OUT,">$out" || die "Can't open '$out': $!\n";
foreach my $chr (sort keys %hash) {
	my @sites=sort {$a<=>$b} keys %{$hash{$chr}};
	my ($pos_a,$pos_b,$start,$end);
	my ($flag,$depth_all,$depth)=(0)x3;
	foreach my $i (0..$#sites) {
		$pos_a=$sites[$i];
		if ($flag==0 && $hash{$chr}{$pos_a}>1000) {
			$start=$pos_a;
			$end=$pos_a;
			$flag=1;
			$depth_all+=$hash{$chr}{$pos_a};
		}
		$i++;
		$pos_b=$sites[$i];
		if (($pos_b-$pos_a)==1 && $hash{$chr}{$pos_b}>1000) {
			$end++;
			$depth_all+=$hash{$chr}{$pos_b};
		}else {
			$depth=int ($depth_all/($end-$start+1));
			print ALL "$chr\_$start\_$end\t$depth\n";
			if ($depth>1000) {
				print OUT "$chr\_$start\_$end\t$depth\n";
			}
			($flag,$depth_all,$depth)=(0)x3;
		}
		if ($i==$#sites) {
			$depth=int ($depth_all/($end-$start+1));
			print ALL "$chr\_$start\_$end\t$depth\n";
			if ($depth>2000) {
				print OUT "$chr\_$start\_$end\t$depth\n";
			}
			($flag,$depth_all,$depth)=(0)x3;
			last;
		}
	}
}
close OUT;
close ALL;

=cut
use strict;
use warnings;
use Data::Dumper;
use File::Basename qw(basename dirname);
use Cwd qw(abs_path);
if (@ARGV!=2) {
	die "\tUsage: $0 <in> <out>\n";
}
my $in=shift;
my $out=shift;
my %hash;
open IN,"$in" || die "Can't open '$in': $!\n";
while (my $line=<IN>) {
	#chrMT   240     A       1       .       E
	chomp $line;
	my ($chr,$pos,$depth)=(split/\s+/,$line)[0,1,3];
	$hash{$chr}{$pos}=$depth;
}
close IN;

open ALL,">$out.all" || die "Can't open '$out.all': $!\n";
open OUT,">$out" || die "Can't open '$out': $!\n";
foreach my $chr (sort keys %hash) {
	my @sites=sort {$a<=>$b} keys %{$hash{$chr}};
	my ($pos_a,$pos_b,$start,$end);
	my ($flag,$depth_all,$depth)=(0)x3;
	foreach my $i (0..$#sites) {
		$pos_a=$sites[$i];
		if ($flag==0) {
			$start=$pos_a;
			$end=$pos_a;
			$flag=1;
			$depth_all+=$hash{$chr}{$pos_a};
		}
		$i++;
		$pos_b=$sites[$i];
		if (($pos_b-$pos_a)==1) {
			$end++;
			$depth_all+=$hash{$chr}{$pos_b};
		}else {
			$depth=int ($depth_all/($end-$start+1));
			print ALL "$chr\_$start\_$end\t$depth\n";
			if ($depth>1000) {
				print OUT "$chr\_$start\_$end\t$depth\n";
			}
			($flag,$depth_all,$depth)=(0)x3;
		}
		if ($i==$#sites) {
			$depth=int ($depth_all/($end-$start+1));
			print ALL "$chr\_$start\_$end\t$depth\n";
			if ($depth>1000) {
				print OUT "$chr\_$start\_$end\t$depth\n";
			}
			($flag,$depth_all,$depth)=(0)x3;
			last;
		}
	}
}
close OUT;
close ALL;


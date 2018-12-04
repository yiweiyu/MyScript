#!/usr/bin/perl
use strict;
use warnings;

if (@ARGV!=3) {
	die "\tUsage: $0 <in_list> <in_prefix> <out_prefix>\n";
	exit;
}
my $list=shift;
my $in_prefix=shift;
my $out_prefix=shift;

open (L,"$list") || die"Can't open $list: $!\n";
my %hash;
<L>;
while (my $line=<L>) {
	#基因1   染色体  外显子  基因二          外显子
	#TPR     chr1    15      ALK     chr2    20
	#KIF5B   chr10   24      ALK     chr2    20
	chomp $line;
	my @temp=split/\s+/,$line;
	my $info="$temp[3]\_$temp[4]\_$temp[5]";
	$hash{$info}=1;
	#print "$info\n";last;
}
close L;


my @temp=glob "$in_prefix*xls";
foreach my $i (@temp) {
	my $mark=(split/\//,$i)[-1];
	$mark=~s/.xls$//;
	open (I,"$i") || die"Can't open '$i': $!\n";
	open (O,">$out_prefix.known.xls")
		or die"Can't open '$out_prefix.known.xls': $!\n";
	<I>;
	while (my $line=<I>) {
		#site1   site2   ratio%  plusmt_ratio    normal_read_num normal_mt_num   fusion_read_num fusion_mt_num   plus_mt_num     fusion_read     fusion_mt       plus_mt
		#chr15:90631808|IDH2:intron:4    chr15:90631871|null     6.211   7.143   151     26      10      2       2       GTCAGTAACCCA:MN00129:11:000H23NKW:1:22103:20709:14379,GTCAGTAACCCA:MN00129:11:000H23NKW:1:23105:2983:19501,GTCAGTAACCCA:MN00129:11:000H23NKW:1:22110:21227:4449,TATTTCGGGGCC:MN00129:11:000H23NKW:1:12104:9051:3401,TATTTCGGGGCC:MN00129:11:000H23NKW:1:13109:17646:13749,TATTTCGGGGCC:MN00129:11:000H23NKW:1:12110:3731:15250,TATTTCGGGGCC:MN00129:11:000H23NKW:1:23102:19110:10566,TATTTCGGGGCC:MN00129:11:000H23NKW:1:21102:7062:2911,GTCAGTAACCCA:MN00129:11:000H23NKW:1:13107:6029:13755,TATTTCGGGGCC:MN00129:11:000H23NKW:1:22102:21068:10485     TATTTCGGGGCC,GTCAGTAACCCA       TATTTCGGGGCC,GTCAGTAACCCA
		chomp $line;
		my ($site1,$site2)=(split/\s+/,$line)[0,1];
		if ($site1=~/null/ or $site2=~/null/) {
			next;
		}
		my ($chr_pos1,$gene_info1)=(split/\|/,$site1)[0,1];
		my ($chr1,$pos1)=(split/:/,$chr_pos1)[0,1];
		my ($gene1,$exORin1,$num1)=(split/:/,$gene_info1)[0,1,2];
		my ($chr_pos2,$gene_info2)=(split/\|/,$site2)[0,1];
		my ($chr2,$pos2)=(split/:/,$chr_pos2)[0,1];
		my ($gene2,$exORin2,$num2)=(split/:/,$gene_info2)[0,1,2];
		#my $want="$gene1\_$chr1\_$num1\_$gene2\_$chr2\_$num2";
		my $want1="$gene1\_$chr1\_$num1";
		my $want2="$gene2\_$chr2\_$num2";
		if ($gene1 eq "ALK") {
			print "$want1\n";
		}
		if (exists $hash{$want1} or exists $hash{$want2}) {
			print O "$line\n";
		}
	}
	close I;
	close O;
}


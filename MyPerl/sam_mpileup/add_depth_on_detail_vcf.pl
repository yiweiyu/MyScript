#!/usr/bin/perl
use strict;
use warnings;

if (@ARGV!=5) {
	die "\tUsage: $0 <in> <detail> <ins> <del> <out> \n";
	exit;
}
my $in=shift;
my $detail=shift;
my $ins=shift;
my $del=shift;
my $out=shift;
my %hash;

open IN,"$in" or die;
while (my $line=<IN>) {
	#Chr     Start   End     Ref     Alt     Gene    Transcript      HGVS_C  HGVS_P  Type    VAF(%)
	#chr1    10412785        10412785        A       G       KIF1B   NM_015074       c.3908A>G       p.N1303S        nonsynonymous SNV       2.936
	if ($line=~/^Chr/) {
		next;
	}
	chomp $line;
	my ($chr,$pos)=(split /\t/,$line)[0,1];
	$hash{$chr}{$pos}=1;
}
close IN;

open SNP,"$detail" or die;
while (my $line=<SNP>) {
	#des     pos     ref     dep     freStat A       G       C       T       total   A_entropy       G_entropy       C_entropy       T_entropy
	#chr10   6054829 G       2659    A:0;G:2659;C:0;T:0;tot:2659     0       2659    0       0       2659    0       1       0       0       0
	chomp $line;
	my ($chr,$pos,$stat)=(split /\t/,$line)[0,1,4];
	if (exists $hash{$chr}{$pos}) {
		my $depth=(split /tot:/,$stat)[1];
		$hash{$chr}{$pos}=$depth;
	}
}
close SNP;

open INS,"$ins" or die;
while (my $line=<INS>) {
	##CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  pindel
	#chr10   76842   .       G       GA      .       PASS    END=76842;HOMLEN=7;HOMSEQ=AAAAAAA;SVLEN=1;SVTYPE=INS    GT:AD   0/0:0,1
	chomp $line;
	if ($line=~/^\#/ || $line=~/^$/) {
		next;
	}
	my ($chr,$pos,$id,$ref,$alt,$q,$filter,$info,$format,$result) = split /\t/,$line;
	($pos,$ref,$alt) = getrealpos($pos,$ref,$alt);
	if (exists $hash{$chr}{$pos}) {
		my @arr = split /:/,$format;
		my $index_AD = 0;
		for my $index (@arr){
			if($index eq "AD"){
				last;
			}
			$index_AD++;
		}
		my $ad_result = (split /:/,$result)[$index_AD];
		my ($dp_ref,$dp_alt) = split /,/,$ad_result;
		my $depth = $dp_ref+$dp_alt;
		$hash{$chr}{$pos}=$depth;
	}
}
close INS;

open DEL,"$del" or die;
while (my $line=<DEL>) {
	##CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  pindel
	#chr10   79546   .       GGA     G       .       PASS    END=79548;HOMLEN=0;SVLEN=-2;SVTYPE=DEL  GT:AD   0/0:0,1
	chomp $line;
	if ($line=~/^\#/ || $line=~/^$/) {
		next;
	}
	my ($chr,$pos,$id,$ref,$alt,$q,$filter,$info,$format,$result) = split /\t/,$line;
	if (exists $hash{$chr}{$pos}) {
		my @arr = split /:/,$format;
		my $index_AD = 0;
		for my $index (@arr){
			if($index eq "AD"){
				last;
			}
			$index_AD++;
		}
		my $ad_result = (split /:/,$result)[$index_AD];
		my ($dp_ref,$dp_alt) = split /,/,$ad_result;
		my $depth = $dp_ref+$dp_alt;
		$hash{$chr}{$pos}=$depth;
	}
}
close DEL;

open O,">$out" or die;
open IN,"$in" or die;
my $header="Chr\tStart\tEnd\tRef\tAlt\tGene\tType\tTranscript\tCHGVS\t"
			."PHGVS\treads\tVAF(%)\n";
print O $header;
while (my $line=<IN>) {
	#Chr     Start   End     Ref     Alt     Gene    Transcript      HGVS_C  HGVS_P  Type    VAF(%)
	#chr1    10412785        10412785        A       G       KIF1B   NM_015074       c.3908A>G       p.N1303S        nonsynonymous SNV       2.936
	if ($line=~/^Chr/) {
		next;
	}
	chomp $line;
	my @a=(split /\t/,$line);
	my $chr=$a[0];
	my $pos=$a[1];
	my $depth=$hash{$chr}{$pos};
	my $info="$a[0]\t$a[1]\t$a[2]\t$a[3]\t$a[4]\t$a[5]\t$a[9]\t$a[6]\t$a[7]\t"
			."$a[8]\t$depth\t$a[10]\n";
	print O $info;
}
close IN;
close O;

sub getrealpos{
	my ($pos,$ref,$alt) = @_;
	my @ref = split //,$ref;
	my @alt = split //,$alt;
	while(@ref){
		if(defined($alt[0]) && $ref[0] eq $alt[0]){
			$pos ++;
			shift @ref;
			shift @alt;
			$pos-- if(!@ref);
		}else{
			last;
		}
	}
	while(@ref){
		if(defined($alt[-1]) && $ref[-1] eq $alt[-1]){
			pop @ref;
			pop @alt;
			$pos-- if(!@ref);
		}else{
			last;
		}
	}
	my ($tmpref,$tmpalt) = ("-","-");
	$tmpref = join "",@ref if(@ref);
	$tmpalt = join "",@alt if(@alt);
	return ($pos,$tmpref,$tmpalt);
}

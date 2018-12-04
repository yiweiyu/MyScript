#!/usr/bin/perl

use strict;

if (@ARGV!=4) {
	die "\tUsage: *.pl <csv> <snpEff> <snplis> <out> \n";
	exit;
}
my $csv=shift;
my $snpEff=shift;
my $lis=shift;
my $out=shift;


open L,"$lis" or die;
my (%ratio_lis,%depth_lis);
while (<L>) {
	#chr12   25398285        25398285        C       A       20.453  na      na      na      na      na      na      na      3491
	#chr7    55242467        55242484        AATTAAGAGAAGCAACAT      -       17.590  na      na      na      na      na      na      na      3104
	chomp;
	my @temp=split(/\t/,$_);
	$ratio_lis{$temp[0]}{$temp[1]}=$temp[5];
	$depth_lis{$temp[0]}{$temp[1]}=$temp[-1];
}
close L;

my %annovar;
open A,"$csv" or die;
while (<A>) {
	#chr12,25398285,25398285,C,A,"exonic","KRAS",,"nonsynonymous SNV","KRAS:NM_004985:exon2:c.34G>T:p.G12C,KRAS:NM_033360:exon2:c.34G>T:p.G12C",Pathogenic|Pathogenic|not provided|Pathogenic|Pathogenic|Likely pathogenic|Pathogenic,Lung_cancer|Non-small_cell_lung_cancer|Endometrial_carcinoma|Neoplasm_of_the_thyroid_gland|Ovarian_Neoplasms|Adenocarcinoma_of_lung|Colorectal_Neoplasms,RCV000013406.5|RCV000038265.3|RCV000119791.1|RCV000418063.1|RCV000420450.1|RCV000431049.1|RCV000435281.1,MedGen:OMIM:SNOMED_CT|MeSH:MedGen:SNOMED_CT|MedGen:OMIM:SNOMED_CT|MeSH:MedGen|MeSH:MedGen|MeSH:MedGen|MeSH:MedGen,C0684249:211980:187875007|D002289:C0007131:254637007|C0476089:608089:254878006|D013964:C0040136|D010051:CN236629|C538231:C0152013|D015179:CN236642,"ID=COSM1140136,COSM516;OCCURENCE=15(stomach),1(central_nervous_system),8(upper_aerodigestive_tract),2(oesophagus),3(peritoneum),1776(lung),18(thyroid),17(haematopoietic_and_lymphoid_tissue),2(testis),2(cervix),4(gastrointestinal_tract_(site_indeterminate)),13(soft_tissue),34(ovary),38(endometrium),5(skin),11(breast),8(small_intestine),1(kidney),130(pancreas),4(liver),15(urinary_tract),1(adrenal_gland),1476(large_intestine),51(biliary_tract),10(prostate)","rs121913530"
	#chr7,55242467,55242484,AATTAAGAGAAGCAACAT,-,"exonic","EGFR",,"nonframeshift deletion","EGFR:NM_001346941:exon13:c.1436_1453del:p.479_485del,EGFR:NM_001346897:exon18:c.2102_2119del:p.701_707del,EGFR:NM_001346899:exon18:c.2102_2119del:p.701_707del,EGFR:NM_001346898:exon19:c.2237_2254del:p.746_752del,EGFR:NM_001346900:exon19:c.2078_2095del:p.693_699del,EGFR:NM_005228:exon19:c.2237_2254del:p.746_752del",drug response,Tyrosine_kinase_inhibitor_response,RCV000154328.1,MedGen,CN225347,"ID=COSM12367;OCCURENCE=1(kidney),4(lung),1(central_nervous_system)","rs121913422"
	chomp;
	my @temp=split(/,/,$_);
	$temp[9]=~s/\"//g;
	$temp[8]=~s/\"//g;
	if ($temp[8]=~/nonsynonymous SNV/ or $temp[8]=~/frameshift/ or $temp[8]=~/stopgain/) {
	#if ($temp[8]=~/SNV/ or $temp[8]=~/frameshift/ or $temp[8]=~/stopgain/) {
		if (exists $ratio_lis{$temp[0]}{$temp[1]}) {
			my $depth=$depth_lis{$temp[0]}{$temp[1]};
			$annovar{$temp[0]}{$temp[1]}="$_,$depth\n";
		}else {
			#print "1\t$_\n";
		}
	}
}
close A;

open S,"$snpEff" or die;
open O,">$out" or die;
my (%eff,%dep);
while (<S>) {
	#chr7    55242466        55242484        GAATTAAGAGAAGCAACAT     G       17.59   na      na;ANN=G|disruptive_inframe_deletion|MODERATE|EGFR|ENSG00000146648|transcript|ENST00000275493|protein_coding|19/28|c.2237_2254delAATTAAGAGAAGCAACAT|p.Glu746_Ser752delinsAla|2414/9821|2237/3633|746/1210||,G|disruptive_inframe_deletion|MODERATE|EGFR|ENSG00000146648|transcript|ENST00000455089|protein_coding|18/26|c.2102_2119delAATTAAGAGAAGCAACAT|p.Glu701_Ser707delinsAla|2359/3844|2102/3276|701/1091||,G|disruptive_inframe_deletion|MODERATE|EGFR|ENSG00000146648|transcript|ENST00000454757|protein_coding|19/28|c.2078_2095delAATTAAGAGAAGCAACAT|p.Glu693_Ser699delinsAla|2261/3938|2078/3474|693/1157||,G|sequence_feature|LOW|EGFR|ENSG00000146648|beta-strand:combinatorial_evidence_used_in_manual_assertion|ENST00000275493|protein_coding|19/28|c.2237_2254delAATTAAGAGAAGCAACAT||||||,G|intron_variant|MODIFIER|EGFR|ENSG00000146648|transcript|ENST00000442591|protein_coding|17/17|c.*28+1846_*28+1863delAATTAAGAGAAGCAACAT|||||| na      na      na      na      na      3104
	chomp;
	my @temp=split(/\t/,$_);
	my $len=length $temp[3];
	my $len_2=length $temp[4];
	#if ($temp[1]!=$temp[2] and $len>1) {
	if ($temp[1]!=$temp[2] and $len>1 and $len_2!=$len) {
		$temp[1]+=1;
	}
	if (exists $annovar{$temp[0]}{$temp[1]}) {
		my $depth=$depth_lis{$temp[0]}{$temp[1]};
		my $ratio=$ratio_lis{$temp[0]}{$temp[1]};
		my @a=split(/,/,$annovar{$temp[0]}{$temp[1]});
		my $n=9;
		my $cpInfo=$a[$n];
		my ($gene,$tra,$exin,$cInfo,$pInfo)=(split/\:/,$cpInfo)[0,1,2,3,4];
		if (!defined $pInfo) {
			$pInfo='-';
		}
		my @anno_cp;
		my $m=1;
		while ($m) {
			$cpInfo=$a[$n];
			push @anno_cp,$cpInfo;
			#print "2\t$cpInfo\n";
			if ($cpInfo=~/\"$/ or $n==$#a) {
				last;
			}
			$n++;
		}
		foreach my $i (@a) {
			$i=~s/\"//g;
		}
		my $EffInfo=$temp[7];
		my $mark=0;
		foreach my $i (@anno_cp) {
			$i=~s/\"//g;
			($gene,$tra,$exin,$cInfo,$pInfo)=(split/\:/,$i)[0,1,2,3,4];
			my ($flag,$p3abbr)=&matchCP($a[3],$a[4],$cInfo,$pInfo,$EffInfo);
			if ($flag==1) {
				$mark=1;
				my $want="HGVS\t$a[0]\t$a[1]\t$a[2]\t$a[3]\t$a[4]\t$gene\t"
						."$tra\t$cInfo\t$p3abbr\t$pInfo\t$a[8]\t$ratio\t$depth\n";
				print O $want;
				last;
			}
		}
		if ($mark==0) {
			my $want="HGVS\t$a[0]\t$a[1]\t$a[2]\t$a[3]\t$a[4]\t$gene\t"
					."$tra\t$cInfo\t-\t$pInfo\t$a[8]\t$ratio\t$depth\n";
			print O $want;
		}
	}
}
close S;
close O;



sub matchCP {
	my ($ref,$alt,$c,$p,$info)=@_;
	#print "3\t$ref\t$alt\t$c\t$p\t$info\n";
	my ($cbeg,$cend,$pbeg,$pend,$p3abbr);
	if ($c=~/(\d+)_(\d+)/) {
		$cbeg=$1;
		$cend=$2;
		if ($ref!=~/-/ and $alt!=~/-/) {
			$c="c.$cbeg\_$cend\delins$alt";
		}
		#print "$cbeg\t$cend\t";
	}elsif ($c=~/(\d+)/) {
		$cbeg=$1;
		#print "$cbeg\t";
	}
	if ($p=~/(\d+)_(\d+)/) {
		$pbeg=$1;
		$pend=$2;
		#print "$pbeg\t$pend\t$_\n";
	}elsif ($p=~/(\d+)/) {
		$pbeg=$1;
		#print "$pbeg\t$_\n";
	}elsif ($p eq "") {
		$p="-";
	}
	my @b=split(/\|/,$info);
	my ($temp,$num,$flag)=(0)x3;
	my ($cInfo,$pInfo);
EFF:foreach my $key (@b) {
		$num++;
		if ($num<=1) {
			next;
		}
		if ($key=~/c\./) {
			$cInfo=$key;
			if ($key=~ /(\d+)_(\d+)/) {
				if ($1==$cbeg and $2==$cend) {
					$temp=1;
					next;
				}
			}elsif ($key=~ /(\d+)/) {
				if ($1==$cbeg) {
					$temp=1;
					next;
				}
			}
		}
		if ($key=~/p\./ and $temp==1) {
			$pInfo=$key;
			print "$cInfo\t$pInfo\n";
			#if ($key=~/(\d+)_(\d+)/) {
			if ($key=~/(\d+)_\D+?(\d+)\D+?/) {
				print "$1\t$2\n\n";
				if ($1==$pbeg and $2==$pend) {
					$flag=1;
					$p3abbr=$key;
					last EFF;
				}elsif ($p eq "-") {
					$flag=1;
					$p3abbr=$key;
					last EFF;
				}
			}elsif ($key=~/(\d+)/) {
				print "$1\n\n";
				if ($1==$pbeg) {
					$flag=1;
					$p3abbr=$key;
					last EFF;
				}elsif ($p eq "-") {
					$flag=1;
					$p3abbr=$key;
					last EFF;
				}
			}
		}
	}
	return ($flag,$p3abbr);
}

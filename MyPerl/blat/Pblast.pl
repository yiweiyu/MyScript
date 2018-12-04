#! /usr/bin/perl -w

# Copyright (c) BGI 2003
# Author:Zhangzj@genomics.org.cn
# Program Date:03-04-01  17:20
# Modifier:Zhangzj  ¿‡À∆EBLASTN
# Last Modified:03-04-02 10:26


#*************** Program Annotation *************************
# Programe to parse the BLASTp,tBLASTx,tBLASTn,Blastn result 
# as the excel format(can recognize)
# the output Format adopt Nipx : EblastN.pl
#************************************************************

use strict;
use Carp;
my  $VERSION = '1.0';#03-04-01
$VERSION = '2.0';#03-04-02 add no hits found
use Getopt::Long;
my %opts;

GetOptions(\%opts,"b=s","e=f","i=i","p=i","s=i","l=i","n=s","o=s","h!");

my $usage=<<"USAGE";
       Program : $0
       Version : $VERSION
       Contact : zhangzj\@genomics.org.cn
       Usage :perl $0 [options]
		-b*	[Blast Result]
			Blastp,tBlastn,tBlastx result File
		-e	[Expect Value]Default 10
			Input float 1e-5,1e-10 etc(<).
		-i	[Identity]Default 0
			Input 80 , 90 etc(>).
		-p	[Positive]Default 0
			Input 80 , 90 etc(>).
		-l	[AlignLen Each Hsp]Default 0
			Input 100 , 50 etc(>).
		-s	[Score]Default 0
			Input 300 ,200 etc(>).
		-o	[Output]Default add (-b).list
			Output Filename
		-n	[Output2]Default add (-b).noHits
			Output Filename
		-h	Display this usage infileormation
		*	must be given Argument
USAGE

die $usage if (!$opts{b}|| $opts{h});

my $LEN = ($opts{l})? $opts{l}:0;
my $EXPECT = ($opts{e})?$opts{e}:(10);
my $IDENTITY = ($opts{i})?$opts{i}:0;
my $POSITIVE = ($opts{p})?$opts{p}:0;
my $SCORE = ($opts{s})?$opts{s}:0;
my $out = ($opts{o})?$opts{o}:$opts{b}.'.list';
my $no = ($opts{n})?$opts{n}:$opts{b}.'.Nohits';


#print "******************************\n";
#print "*    Pblast.pl Version:$VERSION   *\n";
#print "******************************\n";
#print "Pblast.pl is Running ... ...\n";
#print_time('Begin');


my ($expect,$score);
my ($identity,$identity1,$identity2);
my ($positive,$positive1,$positive2);
my ($frame1,$frame2);
my ($query_name,$query_len,$query_beg,$query_end);
#my ($sbjct_name,$sbjct_beg,$sbjct_end);
my ($sbjct_name,$sbjct_len,$sbjct_beg,$sbjct_end);
my $frame;
my $Identity;
my $Positive;
my $align = $identity2;
my $l_first = 0;
my $query_first = 0;
my $sbjct_first = 0;
my @NoHits;

open(OUT,">$out") || die $@;

printf OUT "%30s %30s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s \n","Query_name","Sbjct_name","Query_len","Query_beg","Query_end","Sbjct_beg","Sbjct_end","Sbjct_len","Score","Expect","identity","Identity","positive","Positive","Frame";
#printf OUT "%40s %40s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s \n","Query_name","Sbjct_name","Query_len","Query_beg","Query_end","Sbjct_beg","Sbjct_end","Score","Expect","identity","Identity","positive","Positive","Frame";

open(IN,$opts{b}) || die $@;

while(<IN>)
{
	#chomp;
	if (/Query= (\S+)/)
	{
		if($l_first == 1)
		{			
			$Identity = $identity1."/".$identity2;
			$Positive = $positive1."/".$positive2;
			$align = $identity2;
			$frame = 0 if(!defined $frame);
			if($expect <= $EXPECT && $identity >= $IDENTITY && $positive >= $POSITIVE && $identity2 >= $LEN && $score >= $SCORE)
			{
				printf OUT "%30s %30s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n",$query_name,$sbjct_name,$query_len,$query_beg,$query_end,$sbjct_beg,$sbjct_end,$sbjct_len,$score,$expect,$identity,$Identity,$positive,$Positive,$frame;
				#printf OUT "%40s %40s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n",$query_name,$sbjct_name,$query_len,$query_beg,$query_end,$sbjct_beg,$sbjct_end,$score,$expect,$identity,$Identity,$positive,$Positive,$frame;
			}
			$l_first = $query_first = $sbjct_first = 0;
			$expect = $identity = $positive = $align = $score = 0;
		}
		$query_name = $1;
		$query_name =~ s/\s+//;
	}
	elsif (/\((\S+)\s+letters\)/)
	{
		$query_len=$1;
		$query_len=~s/,//;
	}
	elsif (/^>(\S+)\s+(.*)/)
	{
		if($l_first == 1)
		{
			$Identity = $identity1."/".$identity2;
			$Positive = $positive1."/".$positive2;
			$align = $identity2;
			$frame = 0 if(!defined $frame);
			if($expect <= $EXPECT && $identity >= $IDENTITY && $positive >= $POSITIVE && $identity2 >= $LEN && $score >= $SCORE)
			{
				printf OUT "%30s %30s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n",$query_name,$sbjct_name,$query_len,$query_beg,$query_end,$sbjct_beg,$sbjct_end,$sbjct_len,$score,$expect,$identity,$Identity,$positive,$Positive,$frame;
				#printf OUT "%40s %40s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n",$query_name,$sbjct_name,$query_len,$query_beg,$query_end,$sbjct_beg,$sbjct_end,$score,$expect,$identity,$Identity,$positive,$Positive,$frame;
			}
			$l_first = $query_first = $sbjct_first = 0;
			$expect = $identity = $positive = $align = $score = 0;
		}
		$sbjct_name=$1;
#		$sbjct_name=$1." ".$2;
	}
	elsif (/Length = (\d+)/)
	{
		$sbjct_len=$1;
	}#Score = 30.4 bits (67), Expect(2) = 3e-18
	elsif (/Score = (.*?) bits(.*?)(Expect.*?) =\s+(\S+)\s*/)
	{
		if($l_first == 1)
		{
			$Identity = $identity1."/".$identity2;
			$Positive = $positive1."/".$positive2;
			$align = $identity2;
			$frame = 0 if(!defined $frame);
			if($expect <= $EXPECT && $identity >= $IDENTITY && $positive >= $POSITIVE && $identity2 >= $LEN && $score >= $SCORE)
			{
				printf OUT "%30s %30s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n",$query_name,$sbjct_name,$query_len,$query_beg,$query_end,$sbjct_beg,$sbjct_end,$sbjct_len,$score,$expect,$identity,$Identity,$positive,$Positive,$frame;
				#printf OUT "%40s %40s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n",$query_name,$sbjct_name,$query_len,$query_beg,$query_end,$sbjct_beg,$sbjct_end,$score,$expect,$identity,$Identity,$positive,$Positive,$frame;
			}
			$l_first = $query_first = $sbjct_first = 0;
			$expect = $identity = $positive = $align = $score = 0;
		}
		$score=$1;
		$expect=$4;
		$expect=~s/^e/1e/;
	}
	elsif (/Identities = (\d+)\/(\d+)\s+\((.{0,4})%\)\,\s+Positives = (\d+)\/(\d+)\s+\((.{0,4})%\).*/ || /Identities = (\d+)\/(\d+)\s+\((.{0,4})%\)(\,\s+Gaps)?.*/)
	{
		$identity1=$1;
		$identity2=$2;
		$identity=$3;
		#print "$identity\n";
		if(defined $4 && defined $5 && defined $6)
		{
			$positive1 = $4;
			$positive2 = $5;
			$positive = $6;
		}
		else
		{
			$positive1 = $positive2 = $positive = 0;
		}
	}
	elsif (/Frame = (\S+)\s+(\/)?(\s+)?(\S+)?.*/)
	{
		
		if(defined $1 && defined $4)
		{
			$frame = $1."/".$4 ;
		}
		elsif(defined $1)
		{
			$frame = $1;	
		}
		else
		{
			$frame = 0;
		}
	}
	elsif (/Query\:\s+(\d+)\s+\S+\s+(\d+)/)
	{
		if($query_first==0)
		{
			$query_beg=$1;
		}
		$query_first=1;
		$query_end=$2;		
	}
	elsif (/Sbjct\:\s+(\d+)\s+\S+\s+(\d+)/)
	{
		if($sbjct_first==0)
		{
			$sbjct_beg=$1;
		}
		$sbjct_end=$2;
		$sbjct_first=1;
		$l_first = 1;
	}
	elsif (/No hits found/)
	{
		push @NoHits,$query_name;
	}
}


if($l_first == 1 )
{
	$Identity = $identity1."/".$identity2;
	$Positive = $positive1."/".$positive2;
	$align = $identity2;
	$frame = 0 if(!defined $frame);
	if($expect <= $EXPECT && $identity >= $IDENTITY && $positive >= $POSITIVE && $identity2 >= $LEN && $score >= $SCORE)
	{
		printf OUT "%30s %30s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s \n",$query_name,$sbjct_name,$query_len,$query_beg,$query_end,$sbjct_beg,$sbjct_end,$sbjct_len,$score,$expect,$identity,$Identity,$positive,$Positive,$frame;
		#printf OUT "%40s %40s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s\n",$query_name,$sbjct_name,$query_len,$query_beg,$query_end,$sbjct_beg,$sbjct_end,$score,$expect,$identity,$Identity,$positive,$Positive,$frame;
	}
}

close(IN) || die $@;
close(OUT) || die $@;
open(NO,">$no") || die $@;
if(@NoHits)
{
	print NO "Query\n";
	for(@NoHits)
	{
		print NO "$_\n";
	}
}
else
{
	print NO "There are no 'No Hits Found'.\n";
}
close(NO) || die $@;


#print_time(' End ');

sub print_time
{
	my $when = shift || 'now';
	my ($sec, $min, $hour, $day, $mon, $year) = (localtime(time()))[0..5]; 
	my $now = sprintf("%02d:%02d:%02d %4d-%02d-%02d",$hour, $min, $sec, $year+1900, $mon+1, $day);
	print "$when is: $now\n";
}


__END__

=head1 NAME
	
Pblast.pl

=head1 SYNOPSIS

Programe to parse the BLASTp,tBLASTx,tBLASTn,NCBI Blastall result as the win-excel(can recognize).

=head1 DESCRIPTION

Different blast(blastn,blastp,tblastx,blastn) will generate different result.
But input file is the same.

Default Output in the same dir as the blast result
You can change the Output dir set -o ./file -n /NoHits file.

=over 4 

=item Usage

       Program : $0
       Version : $VERSION
       Contact : zhangzj\@genomics.org.cn
       Usage :perl $0 [options]
		-b	[Blast Result]
			Blastp,tBlastn,tBlastx result File
		-e	[Expect Value]Default 10
			Input integer 1e-5,1e-10 etc(<).
		-i	[Identity]Default 0
			Input 80 , 90 etc(>).
		-p	[Positive]Default 0
			Input 80 , 90 etc(>).
		-l	[AlignLen Each Hsp]Default 0
			Input 100 , 50 etc(>).
		-s	[Score]Default 0
			Input 300 ,200 etc(>).
		-o	[Output]Default add (-b).list
			Output Filename
		-h	Display this usage infileormation

=back

=head1 AUTHOR
	
zhangzj@genomics.org.cn

=head1 CHANGES

2003-04-01  17:20 VER 1.0

2003-04-01	20:25 VER 1.2

fix the bugs:
	Parse blastall (has no positive element in HSP) 
	
04-01	21:20 if The blast result is very big,change to  parse line by line
04-02	10:26	fix cannot give the (gaps if not appear)
				simple the 'frame' element 
=head1 SEE ALSO
	
EblastN.pl by Nipx@genomics.org.cn

=head1 COPYRIGHT

Copyright (c) 2002-2 BGI <zhangzj@genomics.org.cn>. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
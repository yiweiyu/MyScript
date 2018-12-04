#!/usr/bin/perl
use strict;
use warnings;

my %aa_abbre = (
	'Gly'=>'G', #¸Ê°±Ëá
	'Ala'=>'A', #±û°±Ëá
	'Val'=>'V', #çÓ°±Ëá
	'Leu'=>'L', #ÁÁ°±Ëá
	'Ile'=>'I', #ÒìÁÁ°±Ëá
	'Phe'=>'F', #±½±û°±Ëá
	'Trp'=>'W', #É«°±Ëá
	'Tyr'=>'Y', #ÀÒ°±Ëá
	'Asp'=>'D', #Ìì¶¬°±Ëá
	'Asn'=>'N', #Ìì¶¬õ£°·
	'Glu'=>'E', #¹È°±Ëá
	'Lys'=>'K', #Àµ°±Ëá
	'Gln'=>'Q', #¹È°±õ£°·
	'Met'=>'M', #¼×Áò°±Ëá
	'Ser'=>'S', #Ë¿°±Ëá
	'Thr'=>'T', #ËÕ°±Ëá
	'Cys'=>'C', #°ëë×°±Ëá
	'Pro'=>'P', #¸¬°±Ëá
	'His'=>'H', #×é°±Ëá
	'Arg'=>'R', #¾«°±Ëá
	'K'=>'Lys',
	'L'=>'Leu',
	'E'=>'Glu',
	'Q'=>'Gln',
	'H'=>'His',
	'N'=>'Asn',
	'S'=>'Ser',
	'R'=>'Arg',
	'A'=>'Ala',
	'W'=>'Trp',
	'C'=>'Cys',
	'G'=>'Gly',
	'D'=>'Asp',
	'F'=>'Phe',
	'Y'=>'Tyr',
	'M'=>'Met',
	'V'=>'Val',
	'T'=>'Thr',
	'P'=>'Pro',
	'I'=>'Ile',
);


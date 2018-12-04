if (@ARGV!=4) {die"Usage: *.pl <blast> <blat> <blast.single> <blat.single>\n";exit;}
open in,"$ARGV[0]";
while (<in>) {
	chomp;
	$name=(split/\s+/,$_)[0];
	$hash1{$name}=1;
}
close in;
open in,"$ARGV[1]";
open out1,">$ARGV[2]";
open out2,">$ARGV[3]";
while (<in>) {
	chomp;
	unless ($_ =~ m/^\d+/) {
		next;
	}
	$name=(split/\s+/,$_)[9];
	if (exists $hash2{$name}) {
		next;
	}
	if (exists $hash1{$name}) {
		delete $hash1{$name};
		$hash2{$name}=1;
	}else {
		print out2 "$name\n";
		$hash2{$name}=1;
	}
}
close in;

foreach $key (keys %hash1) {
	print out1 "$key\n";
}
close out1;
close out2;

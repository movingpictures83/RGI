use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

# Usage perl make_rgi_clusters.pl dataSummary.txt output_centroid_list.txt
# output is
# centroid_id	AMR	ARO1,ARO2,etc

my $rgi_file;
my $output_file = "aro_centroid.list.txt";
my $type;#        = "best";
my $help;

sub input {
  $rgi_file = $_[0];  
}

sub run {
}

sub output {
	$type = "best";
	$output_file = $_[0];

#GetOptions(
#    "input|i:s"  => \$rgi_file,
#    "type|t:s"   => \$type,
#    "output|o:s" => \$output_file,
#    "help|h|?"   => \$help,
#) || die "Error getting options!\n";

#pod2usage( { -verbose => 2, -exitval => 0 } ) if ( $help );

#Probably should set up a verbose tag to level the printing
if ( !$rgi_file ) {

    warn "Please enter in a directory from which to create the ARO map file\n";
    pod2usage( { -verbose => 2, -exitval => 0 } );

}

if ( !-e $rgi_file ) {

    warn "$rgi_file does not exist. Please check...\n";
    pod2usage( { -verbose => 2, -exitval => 0 } )

}

$type = lc($type);

if ( $type ne "best" && $type ne "all" ) {

    warn "Cannot recognize output type. Reverting to default (best)...\n\n";
    $type = "best";

}

my $list;

open( my $ifh, "<", $rgi_file )    or die("Cannot open rgi_file: $!\n");
open( my $ofh, ">", $output_file ) or die("Cannot open output file: $!\n");

while ( <$ifh> ) {

    next if /ORF_ID/;

    chomp;
    my @arr = split "\t", $_;
    if ( $arr[0] =~ /centroid_(\d+)/ ) {

        my $id    = "centroid_$1";
        my $best  = $arr[8];
        my @names = split ", ", $arr[11];
        my @aro   = split ", ", $arr[10];

        if ( $type eq "best" && $best ) {

            for ( my $i = 0 ; $i < scalar(@aro) ; $i++ ) {

                if ( $names[$i] && $names[$i] eq $best ) {

                    $aro[$i] =~ s/(\s)//g;
                    $list->{$id}->{ $aro[$i] }++;

                }

            }

        } else {

            while ( $arr[10] =~ /([^,]+)/g ) { 

                my $aro = $1; 
                $aro =~ s/(\s)//g; 
                $list->{$id}->{$aro}++; 

            }

        }

    }

}

foreach my $id ( keys(%$list) ) {

    my $out = join( ',', keys( %{ $list->{ $id } } ) );
    print $ofh "$id\t$out\n";

}
}

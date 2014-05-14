#!/usr/bin/perl -w

use strict;
use warnings;

use FindBin '$Bin';

use lib $Bin;

use CodeSearchHelper ();

use PPI ();

use List::MoreUtils 'uniq';

use YAML 'Dump';


my %out = ();

while( defined( my $line = <> ) ) {

    chomp( $line );

    next unless( -f $line );

    print STDERR 'Indexing ', $line, '...', "\n";

    my $doc = PPI::Document -> new( $line );

    CodeSearchHelper::scan_calls( $doc, sub {

        my ( $name_str, $name ) = @_;

        push( @{ $out{ $name_str } }, $line );
    } );
}

while( my ( $name, $list ) = each( %out ) ) {

    $out{ $name } = [ uniq( @$list ) ];
}

print Dump( \%out ), "\n";


exit 0;

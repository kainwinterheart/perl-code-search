#!/usr/bin/perl -w

use strict;
use warnings;

use FindBin '$Bin';

use lib $Bin;

use CodeSearchHelper ();

use Getopt::Long 'GetOptions';

use File::Slurp 'slurp';

use YAML 'Load', 'Dump';

use List::MoreUtils 'uniq';

use PPI ();


my $db_file = '';
my $sub_name = '';
my $include_files_info = '';

GetOptions(
    'db=s' => \$db_file,
    'name=s' => \$sub_name,
    'files' => \$include_files_info,
);

unless(
    ( -f $db_file )
    && $sub_name
) {

    die 'Not enough arguments';
}

my $db = Load( scalar( slurp( $db_file ) ) );

unless( exists( $db -> { $sub_name } ) ) {

    die 'No such call in DB';
}

my %output    = ();
my @sub_names = ( $sub_name );
my %files     = ();

while( defined( my $sub_name = shift( @sub_names ) ) ) {

    next unless( exists( $db -> { $sub_name } ) );

    my $local_output = $output{ $sub_name } //= {};

    foreach my $file ( @{ $db -> { $sub_name } } ) {

        my $doc = PPI::Document -> new( $file );

        CodeSearchHelper::scan_calls( $doc, sub {

            my ( $name_str, $name ) = @_;

            return if( $name_str ne $sub_name );

            while( defined( my $parent = $name -> parent() ) ) {

                if( ref( $parent ) eq 'PPI::Statement::Sub' ) {

                    my $parent_name = $parent -> name();

                    unless( exists( $output{ $parent_name } ) ) {

                        push( @sub_names, $parent_name );
                    }

                    $output{ $parent_name } = $local_output -> { $parent_name } //= {};

                    push( @{ $files{ '' . $local_output -> { $parent_name } } }, $file );

                    last;
                }

                $name = $parent;
            }
        } );
    }
}

if( $include_files_info ) {

    while( my ( $name, $list ) = each( %files ) ) {

        $files{ $name } = [ uniq( @$list ) ];
    }

    my @nodes = ( $output{ $sub_name } );

    while( defined( my $node = shift( @nodes ) ) ) {

        while( my ( $name, $list ) = each( %$node ) ) {

            %$list = (
                files => $files{ '' . $list },
                calls => { %$list },
            );

            push( @nodes, $list -> { 'calls' } );
        }
    }

    print Dump( { $sub_name => { calls => $output{ $sub_name } } } ), "\n";

} else {

    print Dump( { $sub_name => $output{ $sub_name } } ), "\n";
}

exit 0;

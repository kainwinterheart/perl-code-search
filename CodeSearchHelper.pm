package CodeSearchHelper;

sub scan_calls {

    my ( $doc, $callback ) = @_;

    my $calls = $doc -> find( sub {

        ref( $_[ 1 ] ) =~ m/^PPI::(?:Token::Word|Statement)$/; # без наследников
    } );

    return unless( defined( $calls ) && ( ref( $calls ) eq 'ARRAY' ) );

    while( defined( my $call = shift( @$calls ) ) ) {

        my $name  = undef;
        my $rcall = ref( $call );

        if( $rcall eq 'PPI::Statement' ) {

            $name = $call -> schild( 0 );

            next if( ref( $name ) !~ m/^PPI::Token::(?:Word|Symbol)$/ ); # без наследников

        } elsif( $rcall eq 'PPI::Token::Word' ) {

            my $prev = $call -> sprevious_sibling();

            if(
                defined( $prev )
                && ( ref( $prev ) eq 'PPI::Token::Operator' )
            ) {
                $name = $call;
            }
        }

        if( defined( $name ) && ref( $name ) ) {

            my $name_str = $name -> content();

            $name_str =~ s/^&//;

            next if( $name_str =~ m/^\W/ );

            $callback -> ( $name_str, $name );

            if( $name =~ m/^(?:\w|::)+::(\w+)$/ ) {

                $callback -> ( $1, $name );
            }
        }
    }

    return;
}

1;

__END__

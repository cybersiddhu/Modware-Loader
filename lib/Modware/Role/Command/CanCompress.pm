package Modware::Role::Command::CanCompress;
{
    $Modware::Role::Command::CanCompress::VERSION = '1.0.0';
}

# Other modules:
use namespace::autoclean;
use Moose::Role;
use MooseX::Params::Validate;
use IO::Compress::Gzip qw($GzipError gzip);

# Module implementation
#

requires 'current_logger';

sub compress {
    my $self = shift;
    my ( $input, $output ) = validated_list(
        \@_,
        input  => { isa => 'Str' },
        output => { isa => 'Str' }
    );

    my $logger = $self->current_logger;
    if ( gzip $input => $output ) {
        $logger->info("compressed $input to $output");
    }
    else {
        $logger->error($GzipError);
    }
}

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Role::Command::CanCompress

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

package Modware::Load::Chado;
{
    $Modware::Load::Chado::VERSION = '1.0.0';
}

use strict;

# Other modules:
use namespace::autoclean;
use Moose;
use YAML qw/LoadFile/;
extends qw/MooseX::App::Cmd::Command/;
with 'MooseX::ConfigFromFile';
with 'Modware::Role::Command::WithIO';
with 'Modware::Role::Command::WithBCS';
with 'Modware::Role::Command::WithLogger';

# Module implementation
#

has '+output'         => ( traits => [qw/NoGetopt/] );
has '+output_handler' => ( traits => [qw/NoGetopt/] );

has '+configfile' => (
    cmd_aliases   => 'c',
    documentation => 'yaml config file to specify all command line options',
    traits        => [qw/Getopt/]
);

sub get_config_from_file {
    my ( $self, $file ) = @_;
    return LoadFile($file);
}

__PACKAGE__->meta->make_immutable;

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Load::Chado

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

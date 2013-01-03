package Modware::Transform::Command;
{
    $Modware::Transform::Command::VERSION = '1.0.0';
}

# Other modules:
use namespace::autoclean;
use Moose;
use YAML qw/LoadFile/;
extends qw/MooseX::App::Cmd::Command/;

# Module implementation
#
with 'MooseX::ConfigFromFile';
with 'Modware::Role::Command::WithIO';
with 'Modware::Role::Command::WithLogger';

has '+configfile' => (
    cmd_aliases   => 'c',
    traits        => [qw/Getopt/],
    documentation => 'yaml config file to specify all command line options'
);

__PACKAGE__->meta->make_immutable;

sub get_config_from_file {
    my ( $self, $file ) = @_;
    return LoadFile($file);
}

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Transform::Command

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

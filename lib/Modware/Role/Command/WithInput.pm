package Modware::Role::Command::WithInput;
{
    $Modware::Role::Command::WithInput::VERSION = '1.0.0';
}

use strict;

# Other modules:
use namespace::autoclean;
use Moose::Role;
use IO::Handle;
use Modware::Load::Types qw/FileObject/;

# Module implementation
#

has 'input' => (
    is            => 'rw',
    isa           => FileObject,
    traits        => [qw/Getopt/],
    cmd_aliases   => 'i',
    coerce        => 1,
    predicate     => 'has_input',
    documentation => 'Name of the input file, if absent reads from STDIN'
);

has 'input_handler' => (
    is      => 'ro',
    isa     => 'IO::Handle',
    traits  => [qw/NoGetopt/],
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return $self->has_input
            ? $self->input->openr
            : IO::Handle->new_from_fd( fileno(STDIN), 'r' );
    }
);

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Role::Command::WithInput

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

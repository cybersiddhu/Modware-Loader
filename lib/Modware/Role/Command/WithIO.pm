package Modware::Role::Command::WithIO;
{
    $Modware::Role::Command::WithIO::VERSION = '1.0.0';
}

use strict;

# Other modules:
use namespace::autoclean;
use Moose::Role;
use Cwd;
use File::Spec::Functions qw/catfile catdir rel2abs/;
use File::Basename;
use IO::Handle;
use MooseX::Types::Path::Class qw/File/;

# Module implementation
#

has 'input' => (
    is            => 'rw',
    isa           => File,
    traits        => [qw/Getopt/],
    cmd_aliases   => 'i',
    coerce        => 1,
    predicate     => 'has_input',
    documentation => 'Name of the input file, if absent reads from STDIN'
);

has 'output' => (
    is            => 'rw',
    isa           => File,
    traits        => [qw/Getopt/],
    cmd_aliases   => 'o',
    coerce        => 1,
    predicate     => 'has_output',
    documentation => 'Name of the output file,  if absent writes to STDOUT'
);

has 'output_handler' => (
    is      => 'ro',
    isa     => 'IO::Handle',
    traits  => [qw/NoGetopt/],
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return $self->has_output
            ? $self->output->openw
            : IO::Handle->new_from_fd( fileno(STDOUT), 'w' );
    }
);

has 'input_handler' => (
    is      => 'ro',
    isa     => 'IO::Handle',
    traits  => [qw/NoGetopt/],
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        if ( $self->has_input ) {
            return $self->input->openr;
        }
        else {
            if ( -t STDIN ) {
                warn "**Cannot read from STDIN**\n";
                $self->usage->die;
            }
            return IO::Handle->new_from_fd( fileno(STDIN), 'r' );
        }
    }
);

sub _build_data_dir {
    return rel2abs(cwd);
}

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Role::Command::WithIO

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

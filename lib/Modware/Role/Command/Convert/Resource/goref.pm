package Modware::Role::Command::Convert::Resource::goref;
{
    $Modware::Role::Command::Convert::Resource::goref::VERSION = '1.0.0';
}

# Other modules:
use namespace::autoclean;
use Moose::Role;
use Carp;
use Path::Class::File;
use List::MoreUtils qw/any firstval/;

# Module implementation
#

requires 'location';

has '_id_stack' => (
    is      => 'rw',
    isa     => 'HashRef',
    traits  => [qw/Hash/],
    default => sub { {} },
    handles => {
        '_add_id'      => 'set',
        '_get_mod_id'  => 'get',
        '_has_id'      => 'defined',
        '_clear_stack' => 'clear'
    }
);

has 'db' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'dictyBase_REF',
    documentation =>
        'Database abbreviations that are used in GO for cross referencing',
    trigger => sub {
        my ( $self, $value ) = @_;
        $self->_db_regex(qr/^$value/);
    }
);

has '_db_regex' => (
    is      => 'rw',
    isa     => 'RegexpRef',
    default => sub {
        my ($self) = @_;
        my $value = $self->db;
        return qr/^$value/;
    },
    lazy => 1
);

sub init_resource {
    my ($self) = @_;
    my $input = Path::Class::File->new( $self->location )->openr;
    local $/ = "\n\n";
    while ( my $line = $input->getline ) {
        next if $line =~ /^\!/;
        my $goref;
        if ( $line =~ /^go_ref_id: (\S+)$/m ) {
            $goref = $1;
        }
        my @externals = ( $line =~ /^external_accession: (\S+)$/gm );
        if (@externals) {
            my $inner_hash;
            for my $xref (@externals) {
                my ( $db, $id ) = split /:/, $xref;
                $inner_hash->{$db} = $id;
            }
            $self->_add_id( $goref, $inner_hash );
        }
    }
    $input->close;
}

sub is_present {
    my ( $self, $id ) = @_;
    if ( $self->_has_id($id) ) {
        my $hash = $self->_get_mod_id($id);
        return 1 if exists $hash->{ $self->db };
    }
}

sub translate {
    my ( $self, $id ) = @_;
    my $hash = $self->_get_mod_id($id);
    return $self->db . ':' . $hash->{ $self->db }
        if defined $hash->{ $self->db };
}

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Role::Command::Convert::Resource::goref

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

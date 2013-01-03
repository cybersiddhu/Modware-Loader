package Modware::Transform::Convert;
{
    $Modware::Transform::Convert::VERSION = '1.0.0';
}

# Other modules:
use namespace::autoclean;
use Carp;
use Moose;
use Moose::Util qw/ensure_all_roles/;
extends qw/Modware::Transform::Command/;

has 'location' => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_location',
    required  => 1,
    documentation =>
        'Full url/path to a resource that will be used by the converter for id translation.'
);

has 'converter' => (
    is            => 'rw',
    isa           => 'Str',
    documentation => 'The converter module to use for id translation'
);

has 'namespace' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'Modware::Role::Command::Convert::Resource',
    documentation =>
        'Base namespace for converter resource roles,  default is Modware::Role::Command::Convert::Resource'
);

sub load_converter {
    my ($self) = @_;
    my $conv_role = $self->namespace . '::' . lc $self->converter;
    $self->meta->make_mutable;
    ensure_all_roles( $self, $conv_role );
    ensure_all_roles( $self, 'Modware::Role::Command::Convert::Identifier' );
    $self->meta->make_immutable;
    croak
        "converted resource haven't implemented the **init_resource** method\n"
        if !$self->can('init_resource');
    $self->init_resource;
}

__PACKAGE__->meta->make_immutable;

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Transform::Convert

=head1 VERSION

version 1.0.0

=head1 NAME

Modware::Transform::Command::modidingoa - [Convert uniprot to mod canonical identifiers present in GOA gaf file]

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

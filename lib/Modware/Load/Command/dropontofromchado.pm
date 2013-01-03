package Modware::Load::Command::dropontofromchado;
{
    $Modware::Load::Command::dropontofromchado::VERSION = '1.0.0';
}
use strict;
use namespace::autoclean;
use Moose;
use Modware::Loader::Ontology::Manager;
use feature qw/say/;
extends qw/Modware::Load::Chado/;

has '+input'         => ( traits => [qw/NoGetopt/] );
has '+input_handler' => ( traits => [qw/NoGetopt/] );
has 'dry_run'        => (
    is            => 'rw',
    isa           => 'Bool',
    lazy          => 1,
    default       => 0,
    documentation => 'Dry run do not commit anything in database'
);

has 'namespace' => (
    is       => 'rw',
    isa      => 'ArrayRef',
    required => 1,
    documentation =>
        'namespace of ontology to be deleted. Multiple namespaces are allowed'
);

has 'partial_lookup' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => 0,
    lazy          => 1,
    documentation => 'Do a partial lookup of namespace instead of exact match'
);

sub execute {
    my ($self)  = @_;
    my $logger  = $self->logger;
    my $manager = Modware::Loader::Ontology::Manager->new;

    $manager->set_logger($logger);
    $manager->set_schema( $self->schema );
    $manager->set_connect_info( $self->connect_info );

    my $guard = $self->schema->txn_scope_guard;

NAME:
    for my $name ( @{ $self->namespace } ) {

        my $cvrow
            = $manager->is_ontology_in_db( $name, $self->partial_lookup );
        if ( !$cvrow ) {
            $logger->error("This ontology do not exist in database");
            next NAME;
        }

        #enable transaction

        my $actual_name = $cvrow->name;
        $logger->info("start deleting ontology $actual_name");
        $manager->delete_ontology($cvrow);
        $logger->info("deleted ontology $actual_name");
    }
    $guard->commit;
    $self->schema->storage->disconnect;
}
1;

__END__

=pod

=head1 NAME

Modware::Load::Command::dropontofromchado

=head1 VERSION

version 1.0.0

=head1 NAME

Modware::Load::Command::dropontofromchado -  Drop ontology from chado database (use sparingly)

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

package Modware::Loader::Adhoc::Role::Ontology::Chado::WithPostgresql;
{
    $Modware::Loader::Adhoc::Role::Ontology::Chado::WithPostgresql::VERSION = '1.0.0';
}

use namespace::autoclean;
use Moose::Role;

sub transform_schema { }

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Loader::Adhoc::Role::Ontology::Chado::WithPostgresql

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

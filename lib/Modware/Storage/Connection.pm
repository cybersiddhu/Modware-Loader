package Modware::Storage::Connection;
{
    $Modware::Storage::Connection::VERSION = '1.0.0';
}
use namespace::autoclean;
use Moose;

has 'dsn' => ( is => 'rw', isa => 'Str' );
has [qw/user password/] => ( is => 'rw', isa => 'Str|Undef' );
has 'attribute'       => ( is => 'rw', isa => 'HashRef' );
has 'extra_attribute' => ( is => 'rw', isa => 'HashRef' );
has 'schema_debug' => ( is => 'rw', isa => 'Bool', default => 0, lazy => 1 );

__PACKAGE__->meta->make_immutable;

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Storage::Connection

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

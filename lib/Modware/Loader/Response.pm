package Modware::Loader::Response;
{
    $Modware::Loader::Response::VERSION = '1.0.0';
}

use namespace::autoclean;
use Moose;

has [qw/is_error is_success/] => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has 'message' => ( is => 'rw', isa => 'Str' );

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Modware::Loader::Response

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

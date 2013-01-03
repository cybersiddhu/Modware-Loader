package Modware::Export;
{
    $Modware::Export::VERSION = '1.0.0';
}
use strict;

# Other modules:
use Moose;
use namespace::autoclean;
extends qw/MooseX::App::Cmd/;

# Module implementation
#

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Export

=head1 VERSION

version 1.0.0

=head1 NAME

<Modware::Export> - [Base application class for writing export command classes]

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

package Modware::Role::Command::Validate::Obo;
{
    $Modware::Role::Command::Validate::Obo::VERSION = '1.0.0';
}

# Other modules:
use strict;
use namespace::autoclean;
use Moose::Role;
use Modware::Loader::Response;
with 'Modware::Role::Command::WithValidationLogger';

requires 'schema';

sub validate_data {
    my ( $self, $node ) = @_;
    return;
}

# Module implementation
#

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Role::Command::Validate::Obo

=head1 VERSION

version 1.0.0

=head1 NAME

<Modware::Role::Command::Validate::Obo> - [Run validations for obo file]

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

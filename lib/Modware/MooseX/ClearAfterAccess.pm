package Modware::MooseX::ClearAfterAccess;
{
    $Modware::MooseX::ClearAfterAccess::VERSION = '1.0.0';
}

use namespace::autoclean;
use Moose ();
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    trait_aliases => [ 'Modware::Meta::Attribute::Trait::ClearAfterAccess' ]
);

1;    # Magic true value required at end of module

package Moose::Meta::Attribute::Custom::Trait::ClearAfterAccess;
{
    $Moose::Meta::Attribute::Custom::Trait::ClearAfterAccess::VERSION
        = '1.0.0';
}

sub register_implementation {
    return 'Modware::Meta::Attribute::Trait::ClearAfterAccess';
}

1;

__END__

=pod

=head1 NAME

Modware::MooseX::ClearAfterAccess

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

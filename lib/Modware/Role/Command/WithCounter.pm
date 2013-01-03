package Modware::Role::Command::WithCounter;
{
    $Modware::Role::Command::WithCounter::VERSION = '1.0.0';
}

# Other modules:
use namespace::autoclean;
use Moose::Role;
use MooseX::Role::Parameterized;

# Module implementation
#

parameter counter_for => (
    isa      => 'ArrayRef',
    required => 1
);

role {
    my $p = shift;
    for my $name ( @{ $p->counter_for } ) {
        has $name => (
            is      => 'rw',
            isa     => 'Num',
            default => 0,
            traits  => [qw/Counter NoGetopt/],
            handles => {
                'set_' . $name   => 'set',
                'incr_' . $name  => 'inc',
                'reset_' . $name => 'reset'
            }
        );
    }
};

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Role::Command::WithCounter

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

package Modware::Iterator::Array;
{
    $Modware::Iterator::Array::VERSION = '1.0.0';
}

# Other modules:
use namespace::autoclean;
use Moose;

# Module implementation
#

has '_stack' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    traits  => [qw/Array/],
    lazy    => 1,
    default => sub { [] },
    handles => {
        'get_by_index' => 'get',
        'add'          => 'push',
        'members'      => 'elements',
        'member_count' => 'count',
        'has_member'   => 'count',
        'sort_member'  => 'sort_in_place'
    }
);

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Iterator::Array

=head1 VERSION

version 1.0.0

=head1 NAME

<Modware::Iterator::Array> - [An array based iterator]

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

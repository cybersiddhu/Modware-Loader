package Modware::Role::WithDataStash;
{
    $Modware::Role::WithDataStash::VERSION = '1.0.0';
}

# Other modules:
use namespace::autoclean;
use MooseX::Role::Parameterized;

# Module implementation
#

parameter create_stash_for => ( isa => 'ArrayRef[Str]' );

role {
    my $p = shift;
    return if not defined $p->create_stash_for;
    for my $name ( @{ $p->create_stash_for } ) {
        has '_'
            . $name
            . '_cache' => (
            is      => 'rw',
            isa     => 'ArrayRef',
            traits  => [qw/Array/],
            handles => {
                'add_to_' . $name . '_cache'           => 'push',
                'clean_' . $name . '_cache'            => 'clear',
                'entries_in_' . $name . '_cache'       => 'elements',
                'count_entries_in_' . $name . '_cache' => 'count'
            },
            lazy    => 1,
            default => sub { [] },
            );

    }

};

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Role::WithDataStash

=head1 VERSION

version 1.0.0

=head1 SYNOPSIS

with Modware::Role::Chado::Helper::WithDataStash => 
       { create_stash_for => [qw/cvterm relationship/] };

=head1 NAME

<Modware::Role::Chado::Helper::WithDataStash> - [Role for generating perl datastructures
to be consumed with BCS's populate method]

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

package Modware::MOD::Registry;
{
    $Modware::MOD::Registry::VERSION = '1.0.0';
}
use namespace::autoclean;
use Moose;

has '_db_map' => (
    is      => 'rw',
    isa     => 'HashRef',
    traits  => [qw/Hash/],
    lazy    => 1,
    default => sub {
        return {
            'DB:GI'      => 'DB:NCBI_gi',
            'GI'         => 'DB:NCBI_gi',
            'protein_id' => 'DB:NCBI_GP'
        };
    },
    handles => {
        'has_alias' => 'defined',
        'get_alias' => 'get'
    }
);

has '_prefix_map' => (
    is      => 'rw',
    isa     => 'HashRef',
    traits  => [qw/Hash/],
    lazy    => 1,
    default => sub {
        return {
            'DB:dictyBase' => 'http://genomes.dictybase.org/id/',
            'DB:NCBI_gi' =>
                'http://www.ncbi.nlm.nih.gov/entrez/viewer.fcgi?val=',
            'DB:NCBI_GP' => 'http://www.ncbi.nlm.nih.gov/protein/'
        };
    },
    handles => { get_url_prefix => 'get', 'has_db' => 'defined' }
);

has '_url_map' => (
    is      => 'rw',
    isa     => 'HashRef',
    traits  => [qw/Hash/],
    lazy    => 1,
    default => sub {
        return {
            'DB:dictyBase' => 'http://genomes.dictybase.org',
            'DB:NCBI_gi'   => 'http://www.ncbi.nlm.nih.gov',
            'DB:NCBI_GP'   => 'http://www.ncbi.nlm.nih.gov'
        };

    },
    handles => { get_url => 'get' }
);

has '_desc_map' => (
    is      => 'rw',
    isa     => 'HashRef',
    traits  => [qw/Hash/],
    lazy    => 1,
    default => sub {
        return {
            'dictyBase' => 'Dictyostelium genome database',
            'NCBI_GP'   => 'NCBI GenPept',
            'NCBI_gi'   => 'NCBI databases'
        };
    },
    handles => { get_description => 'get' }
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Modware::MOD::Registry

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

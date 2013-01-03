package Modware::Loader;
{
    $Modware::Loader::VERSION = '1.0.0';
}

1;

__END__

=pod

=head1 NAME

Modware::Loader

=head1 VERSION

version 1.0.0

=head1 NAME

Modware::Loader -  Command line apps for Chado relational database 

L<Chado|http://gmod.org/wiki/Introduction_to_Chado> is an open-source modular database
schema for biological data. This distribution provides L<MooseX::App::Cmd> based command
line applications to import and export biological data from Chado database.

=head1 INSTALLATION

=head2 Using cpanm

=over

=item

Download a distribution tarball either from a git B<tag> or from <build/develop> branch.

=item

cpanm <tarball>

=back

=head2 Using Build.PL,  cpan and friends

Download the disribution tarball and follow the instruction in the included B<INSTALL> file.

=head2 From the git repository

This is primarilly intended for authors/developers.

=over

=item *

git checkout git://github.com/dictyBase/Modware-Loader.git

=item *

cpanm -n Dist::Zilla

=item *

dzil listdeps --author --missing | cpanm -n

=item *

dzil install

=back

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

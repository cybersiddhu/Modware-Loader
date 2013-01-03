package Modware::Load::Types;
{
    $Modware::Load::Types::VERSION = '1.0.0';
}

use MooseX::Types -declare =>
    [qw/DataDir DataFile FileObject Dsn DbObject ResultSet Row/];
use MooseX::Types::Moose qw/Str Int/;
use Path::Class::File;

subtype DataDir, as Str, where { -d $_ };
subtype DataFile, as Str, where { -f $_ }, message {"File do not exist"};

class_type FileObject, { class => 'Path::Class::File' };
subtype Dsn, as Str, where {/^dbi:(\w+).+$/};

coerce FileObject, from Str, via { Path::Class::File->new($_) };

class_type ResultSet, { class => 'DBIx::Class::ResultSet' };
class_type Row,       { class => 'DBIx::Class::Row' };
subtype DbObject, as ResultSet | Row;

1;

__END__

=pod

=head1 NAME

Modware::Load::Types

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

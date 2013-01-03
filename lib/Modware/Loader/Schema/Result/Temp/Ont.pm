package Modware::Loader::Schema::Result::Temp::Ont;
{
    $Modware::Loader::Schema::Result::Temp::Ont::VERSION = '1.0.0';
}

package Modware::Loader::Schema::Result::Temp::Ont::Core;
{
    $Modware::Loader::Schema::Result::Temp::Ont::Core::VERSION = '1.0.0';
}

use warnings;
use strict;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('tmp_ont');
__PACKAGE__->add_columns(
    'name' => { data_type => 'varchar', size => 1024 } );
__PACKAGE__->add_columns(
    'accession' => { data_type => 'varchar', size => 255 } );
__PACKAGE__->add_columns( 'db_id'      => { data_type => 'int' } );
__PACKAGE__->add_columns( 'cv_id'      => { data_type => 'int' } );
__PACKAGE__->add_columns( 'definition' => { data_type => 'text' } );
__PACKAGE__->add_columns( 'cmmt'       => { data_type => 'text' } );
__PACKAGE__->add_columns(
    'is_obsolete' => { data_type => 'int', default => 0 } );

1;

package Modware::Loader::Schema::Result::Temp::Ont::New;
{
    $Modware::Loader::Schema::Result::Temp::Ont::New::VERSION = '1.0.0';
}
use warnings;
use strict;
use base qw/Modware::Loader::Schema::Result::Temp::Ont::Core/;

__PACKAGE__->table('tmp_cv_new');
__PACKAGE__->add_columns( 'dbxref_id' => { data_type => 'int' } );
__PACKAGE__->add_columns( 'cvterm_id' => { data_type => 'int' } );

1;

package Modware::Loader::Schema::Result::Temp::Ont::Exist;
{
    $Modware::Loader::Schema::Result::Temp::Ont::Exist::VERSION = '1.0.0';
}
use strict;
use base qw/Modware::Loader::Schema::Result::Temp::Ont::New/;
__PACKAGE__->table('tmp_cv_exist');

1;

package Modware::Loader::Schema::Result::Temp::Ont::Xref;
{
    $Modware::Loader::Schema::Result::Temp::Ont::Xref::VERSION = '1.0.0';
}
use strict;
use base qw/Modware::Loader::Schema::Result::Temp::Ont::AltId/;
__PACKAGE__->table('tmp_xref');
1;

package Modware::Loader::Schema::Result::Temp::Ont::RelationAttr;
{
    $Modware::Loader::Schema::Result::Temp::Ont::RelationAttr::VERSION
        = '1.0.0';
}
use strict;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('tmp_relation_attr');
__PACKAGE__->add_columns( 'cvterm_id'      => { data_type => 'integer' } );
__PACKAGE__->add_columns( 'name'           => { data_type => 'varchar' } );
__PACKAGE__->add_columns( 'relation_attr'  => { data_type => 'varchar' } );
__PACKAGE__->add_columns( 'relation_value' => { data_type => 'varchar' } );

package Modware::Loader::Schema::Result::Temp::Ont::AltId;
{
    $Modware::Loader::Schema::Result::Temp::Ont::AltId::VERSION = '1.0.0';
}

use strict;
use base qw/Modware::Loader::Schema::Result::Temp::Ont::Xref/
    __PACKAGE__->table('tmp_alt_ids');
1;

package Modware::Loader::Schema::Result::Temp::Ont::Syn;
{
    $Modware::Loader::Schema::Result::Temp::Ont::Syn::VERSION = '1.0.0';
}

use strict;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('tmp_syn');
__PACKAGE__->add_columns(
    'type_id' => { data_type => 'varchar', size => 1024 } );
__PACKAGE__->add_columns(
    'accession' => { data_type => 'varchar', size => 255 } );
__PACKAGE__->add_columns( 'syn' => { data_type => 'integer' } );

1;

package Modware::Loader::Schema::Result::Temp::Ont::Relation;
{
    $Modware::Loader::Schema::Result::Temp::Ont::Relation::VERSION = '1.0.0';
}
use warnings;
use strict;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('tmp_relation');
__PACKAGE__->add_columns(
    'subject' => { data_type => 'varchar', size => 255 } );
__PACKAGE__->add_columns(
    'predicate' => { data_type => 'varchar', size => 255 } );
__PACKAGE__->add_columns(
    'object' => { data_type => 'varchar', size => 255 } );

1;

1;

__END__

=pod

=head1 NAME

Modware::Loader::Schema::Result::Temp::Ont

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

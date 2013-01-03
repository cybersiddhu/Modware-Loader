package Modware::Loader::Schema::Temporary;
{
    $Modware::Loader::Schema::Temporary::VERSION = '1.0.0';
}

package Modware::Loader::Schema::Temporary::Cvterm;
{
    $Modware::Loader::Schema::Temporary::Cvterm::VERSION = '1.0.0';
}
use strict;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('temp_cvterm');
__PACKAGE__->add_columns(
    'name' => { data_type => 'varchar', size => 1024 } );
__PACKAGE__->add_columns(
    'accession' => { data_type => 'varchar', size => 1024 } );
__PACKAGE__->add_columns(
    'definition' => { data_type => 'varchar', size => 4000 } );
__PACKAGE__->add_columns(
    'cmmnt' => { data_type => 'varchar', size => 4000 } );
__PACKAGE__->add_columns(
    'is_relationshiptype' => { data_type => 'int', default => 0 } );
__PACKAGE__->add_columns(
    'is_obsolete' => { data_type => 'int', default => 0 } );
__PACKAGE__->add_columns( 'cv_id' => { data_type => 'int', nullable => 0 } );
__PACKAGE__->add_columns( 'db_id' => { data_type => 'int', nullable => 0 } );

1;

package Modware::Loader::Schema::Temporary::CvtermRelationship;
{
    $Modware::Loader::Schema::Temporary::CvtermRelationship::VERSION
        = '1.0.0';
}
use strict;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('temp_cvterm_relationship');
__PACKAGE__->add_columns(
    'subject' => { data_type => 'varchar', size => 1024 } );
__PACKAGE__->add_columns(
    'object' => { data_type => 'varchar', size => 1024 } );
__PACKAGE__->add_columns( 'type' => { data_type => 'varchar', size => 256 } );
__PACKAGE__->add_columns(
    'object_db_id' => { data_type => 'int', nullable => 0 } );
__PACKAGE__->add_columns(
    'subject_db_id' => { data_type => 'int', nullable => 0 } );
__PACKAGE__->add_columns(
    'type_db_id' => { data_type => 'int', nullable => 0 } );
1;

package Modware::Loader::Schema::Temporary::Cvtermsynonym;
{
    $Modware::Loader::Schema::Temporary::Cvtermsynonym::VERSION = '1.0.0';
}
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('temp_cvterm_synonym');
__PACKAGE__->add_columns(
    'accession' => { data_type => 'varchar', size => 256 } );
__PACKAGE__->add_columns( 'syn' => { data_type => 'varchar', size => 1024 } );
__PACKAGE__->add_columns(
    'syn_scope_id' => { data_type => 'integer', nullable => 0 } );
__PACKAGE__->add_columns( 'db_id' => { data_type => 'int', nullable => 0 } );

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Loader::Schema::Temporary

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

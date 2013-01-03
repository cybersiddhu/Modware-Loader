package Modware::Loader::Role::Temp::Obo::WithOracle;
{
    $Modware::Loader::Role::Temp::Obo::WithOracle::VERSION = '1.0.0';
}

use namespace::autoclean;
use Moose::Role;

# Other modules:

# Module implementation
#

has 'on_connect_sql' => (
    is         => 'rw',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub {
        my $self = shift;
        my $sql;
        push @$sql, <<SEQ;
CREATE SEQUENCE sq_tmpobo_tmpobo_id
SEQ

        push @$sql, <<SQL;
CREATE GLOBAL TEMPORARY TABLE tmpobo(
tmpobo_id NUMBER(11, 0) NOT NULL, 
name VARCHAR2(1024) NOT NULL, 
id VARCHAR2(55) NOT NULL, 
namespace VARCHAR2(255) NOT NULL, 
definition CLOB, 
is_obsolete SMALLINT DEFAULT '0' NOT NULL, 
is_relationshiptype SMALLINT DEFAULT '0' NOT NULL, 
PRIMARY KEY(tmpobo_id)
)
ON COMMIT PRESERVE ROWS
SQL

        push @$sql, <<TGR;
CREATE OR REPLACE TRIGGER ai_tmpobo_tmpobo_id
BEFORE INSERT ON tmp
FOR EACH ROW WHEN (
 new.tmpobo_id IS NULL OR new.tmpobo_id = 0
)
BEGIN
 SELECT sq_tmpobo_tmpobo_id.nextval
 INTO :new.tmpobo_id
 FROM dual;
END
TGR

        return $sql;
    }
);

has 'on_disconnect_sql' => (
    is         => 'rw',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub {
        my $self = shift;
        return [
            qq{DROP SEQUENCE sq_tmpobo_tmpobo_id},
            qq{TRUNCATE TABLE tmpobo},
            qq{DROP TABLE tmpobo CASCADE}
        ];
    }
);

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Loader::Role::Temp::Obo::WithOracle

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

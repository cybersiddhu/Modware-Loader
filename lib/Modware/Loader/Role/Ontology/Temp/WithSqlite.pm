package Modware::Loader::Role::Ontology::Temp::WithSqlite;

use namespace::autoclean;
use Moose::Role;
use Encode;
use utf8;
with 'Modware::Loader::Role::Ontology::Temp::Generic';

has cache_threshold =>
    ( is => 'rw', isa => 'Int', lazy => 1, default => 4000 );

after 'load_data_in_staging' => sub {
    my ($self) = @_;
    $self->schema->storage->dbh_do(
        sub {
            my ( $storage, $dbh ) = @_;
            $dbh->do(
                q{CREATE UNIQUE INDEX uniq_name_idx ON temp_cvterm(name,  is_obsolete,  cv_id)}
            );
            $dbh->do(
                q{CREATE UNIQUE INDEX uniq_accession_idx ON temp_cvterm(accession)}
            );
        }
    );
};

around 'load_cvterms_in_staging' => sub {
    my $orig = shift;
    my $self = shift;
    $self->$orig( @_, [ sub { $self->load_synonyms_in_staging(@_) } ] );
};

after 'load_cvterms_in_staging' => sub {
	my ($self) = @_;
    $self->load_cache( 'synonym', 'TempCvtermsynonym', 1 );
}

sub create_temp_statements {
    my ( $self, $storage ) = @_;
    $storage->dbh->do(
        qq{
	        CREATE TEMP TABLE temp_cvterm (
               name varchar(1024) NOT NULL, 
               accession varchar(1024) NOT NULL, 
               is_obsolete integer NOT NULL DEFAULT 0, 
               is_relationshiptype integer NOT NULL DEFAULT 0, 
               definition varchar(4000), 
               cmmnt varchar(4000), 
               cv_id integer NOT NULL, 
               db_id integer NOT NULL
    )}
    );
    $storage->dbh->do(
        qq{
	        CREATE TEMP TABLE temp_cvterm_relationship (
               subject varchar(256) NOT NULL, 
               object varchar(256) NOT NULL, 
               type varchar(256) NULL, 
               subject_db_id integer NOT NULL, 
               object_db_id integer NOT NULL, 
               type_db_id integer NOT NULL
    )}
    );
    $storage->dbh->do(
        qq{
	        CREATE TEMP TABLE temp_cvterm_synonym (
               accession varchar(256) NOT NULL, 
               syn varchar(1024) NOT NULL, 
               syn_scope_id integer NOT NULL, 
               db_id integer NOT NULL
    )}
    );
}

sub drop_temp_statements {
}

1;

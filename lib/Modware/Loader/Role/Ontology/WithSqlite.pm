package Modware::Loader::Role::Ontology::WithSqlite;

# Other modules:
use namespace::autoclean;
use Moose::Role;
use feature qw/say/;

# Module implementation
#

has cache_threshold =>
    ( is => 'rw', isa => 'Int', lazy => 1, default => 2000 );

sub transform_schema { }

sub create_temp_statements {
    my ( $self, $storage ) = @_;
    $storage->dbh->do(
        qq{
	        CREATE TEMPORARY TABLE temp_cvterm (
               name varchar(1024) NOT NULL, 
               accession varchar(1024) NOT NULL, 
               is_obsolete integer NOT NULL DEFAULT 0, 
               is_relationshiptype integer NOT NULL DEFAULT 0, 
               definition text, 
               comment text, 
               cv_id integer NOT NULL, 
               db_id integer NOT NULL
    )}
    );
    $storage->dbh->do(
        qq{
	        CREATE TEMPORARY TABLE temp_accession (
               accession varchar(256) NOT NULL 
    )}
    );
    $storage->dbh->do(
        qq{
	        CREATE TEMPORARY TABLE temp_cvterm_relationship (
               subject varchar(1024) NOT NULL, 
               object varchar(1024) NOT NULL, 
               type varchar(1024) NULL 
    )}
    );
}

sub drop_temp_statements {
}

sub create_dbxrefs {
    my ( $self, $storage, $dbh ) = @_;
    $dbh->do(
        q{
    		INSERT INTO temp_accession(accession)
			SELECT tmcv.accession FROM temp_cvterm tmcv
			LEFT JOIN dbxref ON tmcv.accession=dbxref.accession
			INNER JOIN db ON db.db_id = tmcv.db_id
			WHERE dbxref.accession is NULL
			}
    );
    my $rows = $dbh->do(
        q{
			INSERT INTO dbxref(accession, db_id)
			SELECT tmcv.accession, tmcv.db_id FROM temp_cvterm tmcv
			LEFT JOIN dbxref ON tmcv.accession=dbxref.accession
			INNER JOIN db ON db.db_id = tmcv.db_id
			WHERE dbxref.accession is NULL
			}
    );
    return $rows;
}

sub create_cvterms {
    my ( $self, $storage, $dbh ) = @_;
    my $rows = $dbh->do(
        q{
    		INSERT INTO cvterm(name, is_obsolete, is_relationshiptype,
    		  definition, cv_id, dbxref_id)
			SELECT tmcv.name,tmcv.is_obsolete,tmcv.is_relationshiptype, 
			tmcv.definition,tmcv.cv_id,dbxref.dbxref_id 
			FROM temp_cvterm tmcv,temp_accession tmacc, dbxref,cv
			WHERE tmcv.accession=tmacc.accession
			AND dbxref.accession=tmcv.accession
			AND dbxref.db_id=tmcv.db_id
			}
    );
    return $rows;
}

sub update_cvterm_names {
    my ( $self, $storage, $dbh ) = @_;
#SQLite do not support JOINS in update statements,  so it's need to be done in few
#more steps
#This will update the name of cvterms.
    my $data = $dbh->selectall_arrayref(
        q{
    	SELECT fresh.* FROM (
    	   SELECT tmcv.name fname, cvterm.name oname, cvterm.cvterm_id
    	   FROM temp_cvterm tmcv, dbxref, cvterm
    	   WHERE dbxref.accession = tmcv.accession
    	   AND dbxref.db_id=tmcv.db_id
    	   AND cvterm.dbxref_id=dbxref.dbxref_id
    	) AS fresh
    	WHERE fresh.fname != fresh.oname
    }, { Slice => {} }
    );
    for my $frow (@$data) {
        $self->logger->info(
            sprintf( "old:%s\tnew:%s", $frow->{oname}, $frow->{fname} ) );
        my $dbrow
            = $self->schema->resultset('Cv::Cvterm')
            ->find( $frow->{cvterm_id} )
            ->update( { name => $frow->{fname} } );
    }
    return scalar @$data;
}

sub update_cvterms {
    my ( $self, $storage, $dbh ) = @_;
# This will update definition and status of all cvterms, as usual it is more work in case of SQLit existing cvterms
    my $data = $dbh->selectall_arrayref(
        q{
    		SELECT cvterm.cvterm_id, tmcv.definition, tmcv.is_obsolete 
    		 FROM cvterm, dbxref, temp_cvterm tmcv
    		 WHERE  dbxref.dbxref_id=cvterm.dbxref_id
    		 AND  tmcv.accession = dbxref.accession
    		 AND  tmcv.db_id = dbxref.db_id
    		 WHERE 
    		  NOT EXISTS (
    		    SELECT temp_accession.accession 
    		    FROM temp_accession
    		 )
    	}, { Slice => {} }
    );
    for my $trow (@$data) {
        $self->schema->resultset('Cv::Cvterm')->find( $trow->{cvterm_id} )
            ->update(
            {   definition  => $trow->{definition},
                is_obsolete => $trow->{is_obsolete}
            }
            );
    }
    return scalar @$data;
}

sub merge_comments {
    return 0;
}

sub create_relations {
    my ( $self, $storage, $dbh ) = @_;
    my $rows = $dbh->do(
        q{
    	INSERT INTO cvterm_relationship(object_id, subject_id, type_id)
    	SELECT object.cvterm_id, subject.cvterm_id, type.cvterm_id
    	FROM temp_cvterm_relationship tmprel
    	INNER JOIN cvterm object ON
    	  tmprel.object = object.name
		INNER JOIN cvterm subject ON
		  tmprel.subject = subject.name
		INNER JOIN cvterm type ON
		  tmprel.type = type.name
		 EXCEPT
    	SELECT cvrel.object_id, cvrel.subject_id, cvrel.type_id
    	FROM cvterm_relationship cvrel
    }
    );
    return $rows;
}

1;    # Magic true value required at end of module

__END__

=head1 NAME

Modware::Loader::Role::Chado::BCS::Engine::Oracle


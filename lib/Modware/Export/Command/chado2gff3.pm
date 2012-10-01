package Modware::Export::Command::chado2gff3;
use strict;

# Other modules:
use namespace::autoclean;
use Moose;
use Bio::GFF3::LowLevel qw/gff3_format_feature/;
extends qw/Modware::Export::Chado/;

# Module implementation
#

has 'tolerate_missing' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
    documentation =>
        'Tolerate and output GFF3 features even if specs are not fulfilled. 
	                  Currently output Target attribute if start and end values are absent
	                  Default is off'
);

has 'write_sequence' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
    documentation =>
        'To write the fasta sequence(s) of reference feature(s),  default is true'
);

has 'exclude_mitochondrial' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
    documentation =>
        'Exclude mitochondrial genome,  default is to include if it is present'
);

has 'only_mitochondrial' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
    documentation =>
        'Output only mitochondrial genome if it is present,  default is false'
);

has 'include_aligned_feature' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    traits  => [qw/Array/],
    default => sub { [] },
    lazy    => 1,
    handles => {
        all_aligned_features           => 'elements',
        add_aligned_feature_to_include => 'push',
        has_aligned_features           => 'count'
    },
    documentation =>
        'Additional aligned feature(s) such as BLAST and EST to include in the output'
);

has 'include_align_parts' => (
    is      => 'rw',
    isa     => 'Bool',
    lazy    => 1,
    default => 0,
    documentation =>
        'Group the aligned feature with one or more match_part feature'
);

has 'feature_name' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
    trigger => sub {
        my ($self) = @_;
        if ( $self->has_coderef('read_seq_id') ) {
            $self->register_handler( 'read_seq_id',
                sub { $self->read_seq_id_by_name(@_) } );
        }
    },
    documentation =>
        'Output feature name instead of sequence id in the seq_id field,  default is off.'
);

has 'extra_gene_model' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    traits  => [qw/Array/],
    default => sub { [] },
    lazy    => 1,
    handles => {
        'extra_gene_models'     => 'elements',
        'add_extra_gene_model'  => 'push',
        'has_extra_gene_models' => 'count'
    },
    documentation =>
        'Source name of additional gene models/predictions/transcript models that are outside of canonical model'

);

has 'reference_type' => (
    isa         => 'Str',
    is          => 'rw',
    traits      => [qw/Getopt/],
    cmd_aliases => 'rt',
    documentation =>
        'The SO type of reference feature,  default is supercontig',
    default => 'supercontig',
    lazy    => 1
);

has 'taxon_id' => (
    isa           => 'Int',
    is            => 'rw',
    predicate     => 'has_taxon_id',
    traits        => [qw/NoGetopt/],
    documentation => 'NCBI taxon id,  used for GFF3 header output,  optional'
);

augment 'execute' => sub {
    my ($self) = @_;
    my $logger = $self->logger;
    my $schema = $self->schema;

    if ( $self->exclude_mitochondrial ) {
        $self->register_handler( 'read_reference_feature' =>
                sub { $self->read_reference_feature_without_mito(@_) } );
    }
    if ( $self->only_mitochondrial ) {
        $self->register_handler(
            'read_reference_feature' => sub {
                $self->read_mito_reference_feature(@_);
            }
        );
    }

    my $dbrow = $self->_organism_result;

    ## -- writing the header is a must,  so no coderef is necessary
    my $output = $self->output_handler;
    $output->print("##gff-version\t3\n");

    my $reference_rs = $self->get_coderef('read_reference_feature')
        ->( $dbrow, $self->reference_type );

SEQUENCE_REGION:
    while ( my $row = $reference_rs->next ) {
        my $seq_id = $self->get_coderef('read_seq_id')->($row);
        next SEQUENCE_REGION if !$seq_id;
        $self->get_coderef('write_sequence_region')
            ->( $row, $seq_id, $output );
    }
    $logger->log("Finished writing sequence region");

    # reset the cursor to read from start
    $reference_rs->reset;
REFERENCE:
    while ( my $ref_dbrow = $reference_rs->next ) {
        my $seq_id = $self->get_coderef('read_seq_id')->($ref_dbrow);
        next REFERENCE if !$seq_id;
        $logger->log("Starting GFF3 output of $seq_id");
        next
            if !$self->get_coderef('write_reference_feature')
                ->( $ref_dbrow, $seq_id, $output );

        my $contig_rs = $self->get_coderef('read_contig')->($ref_dbrow);
        while ( my $row = $contig_rs->next ) {
            $self->get_coderef('write_contig')->( $row, $seq_id, $output );
        }

        ## -- gene
        my $gene_rs = $self->read_gene_feature($ref_dbrow);
        while ( my $grow = $gene_rs->next ) {
            $self->_gene2gff3_feature( $grow, $seq_id );
        }

        if ( $self->has_extra_gene_models ) {
            for my $source ( $self->extra_gene_models ) {
                my $rs = $self->get_coderef('read_extra_gene_model')
                    ->( $ref_dbrow, $source );
                while ( my $row = $rs->next ) {
                    $self->get_coderef('write_extra_gene_model')
                        ->( $row, $seq_id, $output );
                }
            }
        }

        ##  --read and write alignments
        if ( $self->has_aligned_features ) {
            for my $type ( $self->all_aligned_features ) {
                my $rs = $self->get_coderef('read_aligned_feature')
                    ->( $ref_dbrow, $type );
            OVERLAPPING:
                while ( my $row = $rs->next ) {
                    $self->get_coderef('write_aligned_feature')->(
                        $row, $seq_id, $output, $self->include_align_parts
                    );
                    if ( $self->include_align_parts ) {
                        my $subrs
                            = $self->get_coderef('read_aligned_subfeature')
                            ->($row);
                        $self->get_coderef('write_aligned_subfeature')
                            ->( $subrs, $row, $seq_id, $output );
                    }
                }
            }
        }
        $logger->log("Finished GFF3 output of $seq_id");
    }

    # end writing all features
    $output->print("###\n");

    # write sequences
    if ( $self->write_sequence ) {
        $output->print("##FASTA\n");
        $reference_rs->reset;
        while ( my $row = $reference_rs->next ) {
            my $seq_id = $self->get_coderef('read_seq_id')->($row);
            $self->get_coderef('write_reference_sequence')
                ->( $row, $seq_id, $output );
        }
        $logger->log("Finished writing all sequences");
    }
    $output->close;
};

sub _gene2gff3_feature {
    my ( $self, $gene_dbrow, $seq_id ) = @_;
    my $output = $self->output_handler;
    return
        if !$self->get_coderef('write_gene_feature')
            ->( $gene_dbrow, $seq_id, $output );
    my $gene_id = $self->_chado_feature_id($gene_dbrow);

    my @transcript_dbrows
        = $self->get_coderef('read_transcript_feature')->($gene_dbrow);
    for my $trow (@transcript_dbrows) {
        next
            if !$self->get_coderef('write_transcript_feature')
                ->( $trow, $seq_id, $gene_id, $output );
        my $trans_id    = $self->_chado_feature_id($trow);
        my @exon_dbrows = $self->get_coderef('read_exon_feature')->($trow);

        for my $erow (@exon_dbrows) {
            $self->get_coderef('write_exon_feature')
                ->( $erow, $seq_id, $trans_id, $output );
            if ( $trow->type->name eq 'mRNA' ) {

                # process for CDS here
                $self->get_coderef('write_cds_feature')
                    ->( $erow, $seq_id, $output );
            }
        }
    }
}

sub read_aligned_feature {
    my ( $self, $dbrow, $type ) = @_;
    return $dbrow->search_related( 'featureloc_srcfeatures', {} )
        ->search_related(
        'feature',
        { 'type.name' => $type },
        { join        => 'type' }
        );
}

sub read_aligned_subfeature {
    my ( $self, $dbrow ) = @_;
    return $dbrow->search_related(
        'feature_relationship_objects',
        { 'type.name' => 'part_of' },
        { join        => 'type' }
    )->search_related('subject');
}

sub write_aligned_subfeature {
    my ( $self, $rs, $parent, $seq_id, $output ) = @_;
    my $source    = $self->gff_source($parent) || undef;
    my $type      = 'match_part';
    my $parent_id = $self->_chado_feature_id($parent);

    while ( my $dbrow = $rs->next ) {
        my $hashref;
        $hashref->{seq_id} = $seq_id;
        $hashref->{type}   = $type;
        $hashref->{source} = $source;

        my $floc_rs = $dbrow->featureloc_features( { rank => 0 },
            { order_by => { -asc => 'fmin' } } );
        my $floc_row;
        if ( $floc_row = $floc_rs->first ) {
            $hashref->{start}  = $floc_row->fmin + 1;
            $hashref->{end}    = $floc_row->fmax;
            $hashref->{strand} = $floc_row->strand == -1 ? '-' : '+';
        }
        else {
            $self->logger->log(
                "No feature location relative to genome is found: Skipped from output"
            );
            next;
        }
        $hashref->{phase} = undef;
        $hashref->{attributes}->{ID} = [ $self->_chado_feature_id($dbrow) ];
        $hashref->{attributes}->{Parent} = [$parent_id];

        my $target = $parent_id;
        my $floc2_rs = $dbrow->featureloc_features( { rank => 1 } );
        if ( my $row = $floc2_rs->next ) {
            $target .= "\t" . ( $row->fmin + 1 ) . "\t" . $row->fmax;
            if ( my $strand = $row->strand ) {
                $strand = $strand == -1 ? '-' : '+';
                $target .= "\t$strand";
            }
        }
        else {
            $self->logger->log(
                "No feature location relative to itself(query) is found");
            if ( !$self->tolerate_missing ) {
                $self->logger->log("Skipped target attribute from output");
                $output->print( gff3_format_feature($hashref) );
                return;
            }
        }
        $hashref->{attributes}->{Target} = [$target];

        if ( my $gap_str = $floc_row->residue_info ) {
            $hashref->{attributes}->{Gap} = [$gap_str];
        }
        $output->print( gff3_format_feature($hashref) );
    }
}

sub write_aligned_feature {
    my ( $self, $dbrow, $seq_id, $output, $align_parts ) = @_;
    my $hashref;
    $hashref->{seq_id} = $seq_id;
    $hashref->{source} = $self->gff_source($dbrow) || undef;

    my $type = $dbrow->type->name;
    $type = $type . '_match' if $type !~ /match/;
    $hashref->{type} = $type;

    my $floc_rs = $dbrow->featureloc_features( { rank => 0 } );
    my $floc_row;
    if ( $floc_row = $floc_rs->first ) {
        $hashref->{start}  = $floc_row->fmin + 1;
        $hashref->{end}    = $floc_row->fmax;
        $hashref->{strand} = $floc_row->strand == -1 ? '-' : '+';
    }
    else {
        $self->logger->log(
            "No feature location relative to genome is found: Skipped from output"
        );
        return;
    }
    $hashref->{phase} = undef;

    my $analysis_rs = $dbrow->search_related( 'analysisfeatures', {} );
    if ( my $row = $analysis_rs->first ) {
        $hashref->{score} = $row->significance;
    }
    else {
        $hashref->{score} = undef;
    }

    my $id = $self->_chado_feature_id($dbrow);
    $hashref->{attributes}->{ID} = [$id];
    if ( my $name = $dbrow->name ) {
        $hashref->{attributes}->{Name} = [$name];
    }

    if ($align_parts)
    {    ## -- target attribute will be added in the feature parts
        $output->print( gff3_format_feature($hashref) );
        return;
    }

    my $target = $id;
    my $floc2_rs = $dbrow->featureloc_features( { rank => 1 } );
    if ( my $row = $floc2_rs->next ) {
        $target .= "\t" . ( $row->fmin + 1 ) . "\t" . $row->fmax;
        if ( my $strand = $row->strand ) {
            $strand = $strand == -1 ? '-' : '+';
            $target .= "\t$strand";
        }
    }
    else {
        $self->logger->log(
            "No feature location relative to itself(query) is found");
        if ( !$self->tolerate_missing ) {
            $self->logger->log("Skipped target attribute from output");
            $output->print( gff3_format_feature($hashref) );
            return;
        }
    }
    $hashref->{attributes}->{Target} = [$target];

    if ( my $gap_str = $floc_row->residue_info ) {
        $hashref->{attributes}->{Gap} = [$gap_str];
    }
    $output->print( gff3_format_feature($hashref) );
}

sub read_extra_gene_model {
    my ( $self, $dbrow, $source ) = @_;
    return $dbrow->search_related( 'featureloc_srcfeatures', {} )
        ->search_related(
        'feature',
        {   'type.name'        => { like => '%RNA' },
            'dbxref.accession' => $source
        },
        { join => [ 'type', { 'feature_dbxrefs' => 'dbxref' } ] }
        );
}

sub write_extra_gene_model {
    my ( $self, $dbrow, $seq_id, $output ) = @_;
    my $hash = $self->_dbrow2gff3hash( $dbrow, $seq_id );
    $output->print( gff3_format_feature($hash) );

    my @exon_dbrows = $self->read_exon_feature($dbrow);
    return if !@exon_dbrows;

    my $trans_id = $self->_chado_feature_id($dbrow);
    for my $erow (@exon_dbrows) {
        $self->write_exon_feature( $erow, $seq_id, $trans_id, $output );
    }
}

has '_hook_stack' => (
    is      => 'rw',
    isa     => 'HashRef[CodeRef]',
    traits  => [qw/Hash/],
    lazy    => 1,
    builder => '_build_hook_stack',
    handles => {
        get_coderef      => 'get',
        get_all_coderefs => 'keys',
        register_handler => 'set',
        has_coderef      => 'defined'
    }
);

sub _build_hook_stack {
    my ($self) = @_;
    return {
        read_reference_feature  => sub { $self->read_reference_feature(@_) },
        read_seq_id             => sub { $self->read_seq_id(@_) },
        write_meta_header       => sub { $self->write_meta_header(@_) },
        write_sequence_region   => sub { $self->write_sequence_region(@_) },
        write_reference_feature => sub { $self->write_reference_feature(@_) },
        read_gene_feature       => sub { $self->read_gene_feature(@_) },
        write_gene_feature      => sub { $self->write_gene_feature(@_) },
        read_transcript_feature => sub { $self->read_transcript_feature(@_) },
        write_transcript_feature =>
            sub { $self->write_transcript_feature(@_) },
        read_exon_feature  => sub { $self->read_exon_feature(@_) },
        write_exon_feature => sub { $self->write_exon_feature(@_) },
        write_cds_feature  => sub { $self->write_cds_feature(@_) },
        write_reference_sequence =>
            sub { $self->write_reference_sequence(@_) },
        write_aligned_feature => sub { $self->write_aligned_feature(@_) },
        read_aligned_feature  => sub { $self->read_aligned_feature(@_) },
        write_aligned_subfeature =>
            sub { $self->write_aligned_subfeature(@_) },
        read_aligned_subfeature => sub { $self->read_aligned_subfeature(@_) },
        write_extra_gene_model  => sub { $self->write_extra_gene_model(@_) },
        read_extra_gene_model   => sub { $self->read_extra_gene_model(@_) },
        read_contig             => sub { $self->read_contig(@_) },
        write_contig            => sub { $self->write_contig(@_) }
    };
}

__PACKAGE__->meta->make_immutable;

1;    # Magic true value required at end of module

__END__

=head1 NAME

Modware::Export::Command::chado2gff3 -  Export GFF3 file from chado database


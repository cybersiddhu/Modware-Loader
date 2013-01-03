package Modware::Transform::Command::blast2gbrowsegff3;
{
    $Modware::Transform::Command::blast2gbrowsegff3::VERSION = '1.0.0';
}

# Other modules:
use namespace::autoclean;
use Moose;
use Bio::SearchIO;
use Bio::Search::Result::GenericResult;
use Bio::Search::Hit::GenericHit;
use Bio::GFF3::LowLevel qw/gff3_format_feature/;
use Modware::SearchIO::Blast;
extends qw/Modware::Transform::Command/;
with 'Modware::Role::Tblastn::Filter';

has 'merge_contained' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
    lazy    => 1,
    documentation =>
        'Merge HSPs where both of their endpoints are completely contained within other. The merged HSP will retain attributes of the largest one,  default is false. If true,  *orf_only* option takes precedence.'
);

has 'max_intron_length' => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
    lazy    => 1,
    documentation =>
        'Max intron length threshold for spliting hsps into separate hit groups,  only true for TBLASTN,  default in none.'
);

has 'orf_only' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
    lazy    => 1,
    trigger => sub {
        my ($self) = @_;
        $self->start_codon_only(1);
        $self->remove_stop_codon(1);
    },
    documentation =>
        'Activates both start_codon_only and remove_stop_codon options,  default is off. True for only TBLASTN'
);

has 'start_codon_only' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
    lazy    => 1,
    documentation =>
        'Keep alignments only with start codon,  default is off. True for only TBLASTN'
);

has 'remove_stop_codon' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
    lazy    => 1,
    documentation =>
        'Remove stop codon from the alignment,  default is off. True for only TBLASTN'
);

has 'format' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'blast',
    lazy    => 1,
    documentation =>
        'Type of blast output,  either blast(text) or blastxml. For blastxml format the query name is parsed from query description'
);

has '+input' =>
    ( documentation => 'blast result file if absent reads from STDIN' );
has 'source' => (
    is          => 'rw',
    isa         => 'Str',
    traits      => [qw/Getopt/],
    cmd_aliases => 's',
    lazy        => 1,
    default     => sub {
        my ($self) = @_;
        return lc $self->_result_object->algorithm;
    },
    documentation =>
        'the source field of GFF output,  default will the algorithm name'
);

has 'primary_tag' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $algorithm = lc $self->_result_object->algorithm;
        my $tag;
        if ( $algorithm eq 'blastn' ) {
            $tag = 'nucleotide_match';
        }
        elsif ( $algorithm eq 'blastp' ) {
            $tag = 'protein_match';
        }
        elsif ( $algorithm eq 'tblastn' ) {
            $tag = 'protein_match';
        }
        else {
            $tag = 'translated_nucleotide_match';
        }
        return $tag;
    },
    documentation =>
        'The type of feature(column3) that will be used for grouping, by default it will be guessed from the blast algorithm',

);

has '_result_object' => (
    is        => 'rw',
    isa       => 'Bio::Search::Result::GenericResult',
    predicate => 'has_result_object'
);

has 'hit_id_parser' => (
    is  => 'rw',
    isa => 'Str',
    documentation =>
        'hit id parser for the header line,  default is to use none. ncbi_gi, regular and general parsers are available'
);

has 'query_id_parser' => (
    is  => 'rw',
    isa => 'Str',
    documentation =>
        'query id parser for the header line,  default is to use none. ncbi_gi , regular and general parsers are available'
);

has 'desc_parser' => (
    is  => 'rw',
    isa => 'Str',
    documentation =>
        'description parser for the header line,  default is to use none. ncbi parser is available'
);

has '_desc_parser_stack' => (
    is      => 'rw',
    isa     => 'HashRef',
    traits  => [qw/Hash/],
    handles => {
        get_desc_parser      => 'get',
        register_desc_parser => 'set',
    },
    default => sub {
        my ($self) = @_;
        return { 'ncbi' => sub { $self->ncbi_desc_parser(@_) }, };
    },
    lazy => 1
);

has '_parser_stack' => (
    is      => 'rw',
    isa     => 'HashRef',
    traits  => [qw/Hash/],
    handles => {
        get_parser      => 'get',
        register_parser => 'set',
    },
    default => sub {
        my ($self) = @_;
        return {
            'ncbi'    => sub { $self->ncbi_gi_parser(@_) },
            'regular' => sub { $self->regular_parser(@_) },
            'general' => sub { $self->general_parser(@_) }
        };
    },
    lazy => 1
);

sub ncbi_gi_parser {
    my ( $self, $string ) = @_;
    return $string if $string !~ /\|/;
    return ( ( split /\|/, $string ) )[1];
}

sub regular_parser {
    my ( $self, $string ) = @_;
    return $string if $string !~ /\|/;
    return ( ( split /\|/, $string ) )[0];
}

sub general_parser {
    my ( $self, $string ) = @_;
    return $string if $string !~ /\|/;
    return ( ( split /\|/, $string ) )[2];
}

sub ncbi_desc_parser {
    my ( $self, $string ) = @_;
    return $string if $string !~ /\|/;
    my @values = ( split /\|/, $string );
    my $desc = $values[-1];
    $desc =~ s/^\s*//g;
    $desc =~ s/\s*$//g;
    return $desc;
}

sub execute {
    my ($self) = @_;
    my $parser = Modware::SearchIO::Blast->new(
        format => $self->format,
        file   => $self->input_handler
    );
    $self->output_handler->print("##gff-version\t3\n");

    $parser->subscribe( 'filter_result' => sub { $self->filter_result(@_) } );
    $parser->subscribe( 'write_result'  => sub { $self->write_result(@_) } );
    $parser->subscribe( 'write_hit'     => sub { $self->write_hit(@_) } );
    $parser->subscribe( 'filter_hit'    => sub { $self->filter_hit(@_) } );
    $parser->subscribe( 'write_hsp'     => sub { $self->write_hsp(@_) } );
    $parser->process;
}

sub filter_result {
    my ( $self, $event, $result ) = @_;

    # construct a fresh result object
    my $new_result = Bio::Search::Result::GenericResult->new;
    $self->normalize_result_names( $result, $new_result );
    $self->clone_minimal_result_fields( $result, $new_result );

#additional grouping of hsp's by the hit frame and strand as in case of tblastn,  hsp
#belong to separate strand of query gets grouped into the same hit,  however
#for gff3 format they should be splitted in separate hit groups.
    if ( lc $new_result->algorithm eq 'tblastn' ) {
        if ( $self->start_codon_only or $self->remove_stop_codon ) {
            $self->split_hit_by_strand_and_frame( $result, $new_result );
        }
        else {
            $self->split_hit_by_strand( $result, $new_result );
        }
        $event->result_response($new_result);

        if ( $self->max_intron_length ) {

            #further splitting in case max intron length is given
            my $existing_result = $event->result_response;
            my $new_result2     = $self->clone_result($existing_result);
            $self->split_hit_by_intron_length( $existing_result, $new_result2,
                $self->max_intron_length );

            $self->_result_object($new_result2) if !$self->has_result_object;
            $event->result_response($new_result2);
        }

    }
    else {
        $new_result->add_hit($_) for $result->hits;
        $self->_result_object($new_result) if !$self->has_result_object;
        $event->result_response($new_result);
    }
}

sub filter_hit {
    my ( $self, $event, $hit ) = @_;
    if ( $self->remove_stop_codon ) {
        if ( $self->has_stop_codon($hit) ) {
            $event->filter(1);
            return;
        }
    }
    if ( $self->start_codon_only ) {
        if ( !$self->has_start_codon($hit) ) {
            $event->filter(1);
            return;
        }
    }

    return if !$self->merge_contained;

    my @hsps = sort { $a->start('hit') <=> $b->start('hit') } $hit->hsps;
    return if @hsps == 1;

    my $index          = 0;
    my $merged_index   = {};
    my $new_hsps_index = {};
    my $end            = $#hsps;
OUTER:
    for my $i ( 0 .. $end - 1 ) {
        next OUTER if exists $merged_index->{$i};
    INNER:
        for my $y ( $i + 1 .. $end ) {
            if ( $hsps[$i]->end('hit') >= $hsps[$y]->end('hit') ) {
                $merged_index->{$y} = 1;
            }
        }
        $new_hsps_index->{$i} = 1;
    }

    # the last element needs to be checked
    $new_hsps_index->{$end} = 1 if not exists $merged_index->{$end};

    if ( scalar keys %$new_hsps_index ) {
        my $new_hit = $self->clone_hit($hit);
        $new_hit->add_hsp( $hsps[$_] ) for keys %$new_hsps_index;
        $event->hit_response($new_hit);
    }
}

sub write_result {
    my ( $self, $event, $result ) = @_;
    $self->_result_object($result);
}

sub write_hit {
    my ( $self, $event, $hit ) = @_;
    my $output = $self->output_handler;
    my $result = $self->_result_object;

    $output->print(
        gff3_format_feature(
            {   start  => $hit->start('hit'),
                end    => $hit->end('hit'),
                seq_id => $hit->accession,
                strand => $hit->strand('hit') == 1 ? '+' : '-',
                source => $self->source,
                type   => $self->primary_tag,
                score      => sprintf( "%.3g", $hit->significance ),
                attributes => {
                    ID   => [ $hit->name ],
                    Name => [ $result->query_name ],
                    Note => [ $result->query_description ]

                }
            }
        )
    );
}

sub write_hsp {
    my ( $self, $event, $hsp ) = @_;
    my $output = $self->output_handler;
    my $hit    = $hsp->hit;
    my $result = $self->_result_object;

    my @str = $hsp->cigar_string =~ /\d{1,3}[A-Z]?/g;
    my $target = sprintf "%s %d %d", $result->query_name, $hsp->start,
        $hsp->end;
    if ( lc $result->algorithm ne 'tblastn' ) {
        $target .= ' ' . $hsp->strand;
    }

    $output->print(
        gff3_format_feature(
            {   seq_id => $hit->seq_id,
                type   => 'match_part',
                source => $self->source,
                start  => $hsp->start('subject'),
                end    => $hsp->end('subject'),
                strand => $hsp->strand('hit') == 1 ? '+' : '-',
                score      => sprintf( "%.3g", $hsp->significance ),
                attributes => {
                    Gap    => [ join( ' ', @str ) ],
                    Parent => [ $hit->display_name ],
                    Target => [$target],
                }
            }
        )
    );
}

sub normalize_result_names {
    my ( $self, $result, $new_result ) = @_;
    my ( $qname, $qacc );
    if ( $self->format eq 'blastxml' ) {
        $qname
            = $self->query_id_parser
            ? $self->get_parser( $self->query_id_parser )
            ->( $result->query_description )
            : $result->query_description;
        $qacc = $qname;
    }
    else {
        my $qname
            = $self->query_id_parser
            ? $self->get_parser( $self->query_id_parser )
            ->( $result->query_name )
            : $result->query_name;
        $qacc
            = $result->query_accession
            ? $result->query_accession
            : $qname;
    }
    my $qdesc
        = $self->desc_parser
        ? $self->get_desc_parser( $self->desc_parser )
        ->( $result->query_description )
        : $result->query_description;

    $new_result->query_name($qname);
    $new_result->query_accession($qacc);
    $new_result->query_description($qdesc);
}

sub clone_minimal_result_fields {
    my ( $self, $result, $new_result ) = @_;
    $new_result->$_( $result->$_ ) for qw/query_length database_name
        algorithm/;
    $new_result->add_statistic( $_, $result->{statistics}->{$_} )
        for keys %{ $result->{statistics} };
}

sub clone_all_results_fields {
    my ( $self, $result, $new_result ) = @_;
    $self->clone_minimal_result_fields( $result, $new_result );
    $new_result->$_( $result->$_ )
        for qw/query_name query_accession query_description/;
}

sub clone_result {
    my ( $self, $old ) = @_;
    my $new = Bio::Search::Result::GenericResult->new;
    $self->clone_all_results_fields( $old, $new );
    return $new;
}

sub clone_hit {
    my ( $self, $old_hit, $counter ) = @_;
    my $name = $old_hit->name;
    $name .= sprintf( "%01d", $counter ) if $counter;
    my $new_hit = Bio::Search::Hit::GenericHit->new(
        -name      => $name,
        -accession => $old_hit->accession,
        -algorithm => $old_hit->algorithm,
    );
    return $new_hit;
}

__PACKAGE__->meta->make_immutable;

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Transform::Command::blast2gbrowsegff3

=head1 VERSION

version 1.0.0

=head1 NAME

Modware::Transform::Command::blast2gbrowsegff3 - Convert blast output to gff3 file to display in genome browser

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

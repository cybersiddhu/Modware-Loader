package Modware::Loader::Adhoc::Role::Ontology::Chado::WithOracle;
{
    $Modware::Loader::Adhoc::Role::Ontology::Chado::WithOracle::VERSION = '1.0.0';
}

use namespace::autoclean;
use Moose::Role;

sub transform_schema {
    my ($self) = @_;
    my $schema = $self->schema;
    my $source = $self->schema->source('Cv::Cvtermsynonym');
    $source->remove_column('synonym');
    $source->add_column(
        'synonym_' => {
            data_type   => 'varchar',
            is_nullable => 0,
            size        => 1024
        }
    );
    my @sources = (
        'Cv::Cvprop',     'Cv::Cvtermprop',
        'Cv::Dbxrefprop', 'Sequence::Featureprop',
        'Sequence::FeatureCvtermprop'
    );
    for my $name (@sources) {
        my $result_source = $schema->source($name);
        next if !$result_source->has_column('value');
        $result_source->remove_column('value');
        $result_source->add_column(
            'value' => {
                data_type   => 'clob',
                is_nullable => 1
            }
        );
    }
}

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Loader::Adhoc::Role::Ontology::Chado::WithOracle

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

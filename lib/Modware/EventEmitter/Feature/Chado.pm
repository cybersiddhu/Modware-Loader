package Modware::EventEmitter::Feature::Chado;
{
    $Modware::EventEmitter::Feature::Chado::VERSION = '1.0.0';
}

# Other modules:
use namespace::autoclean;
use Moose;
use Modware::MooseX::ClearAfterAccess;
use MooseX::Event '-alias' => {
    on              => 'subscribe',
    remove_listener => 'unsubscribe'
};
use Modware::Load::Types qw/DbObject/;
with 'Modware::Role::Loggable';

# Module implementation
#

has_events
    qw/write_meta_header write_header read_organism write_sequence_region/;
has_events qw/read_reference read_seq_id write_reference/;
has_events qw/read_feature read_subfeature write_feature write_subfeature/;

has 'resource' => ( is => 'rw', isa => 'Bio::Chado::Schema', required => 1 );
has 'response' => (
    is        => 'rw',
    isa       => DbObject,
    predicate => 'has_response',
    traits    => [qw/ClearAfterAccess/]
);

has 'response_id' => (
    is     => 'rw',
    isa    => 'Str',
    traits => [qw/ClearAfterAccess/]
);

has 'msg' => ( is => 'rw', isa => 'Str' );

sub process {
    my ( $self, $log_level ) = @_;

    $self->log_level($log_level) if $log_level;
    $self->use_extended_layout(1);
    my $logger = $self->output_logger;

    $self->emit('write_header');
    $self->emit('write_meta_header');

    $logger->debug('read_organism event');
    $self->emit( 'read_organism' => $self->resource );

    $logger->debug('read_reference event');
    $self->emit( 'read_reference' => $self->response );
    my $response = $self->response;
    $logger->debug('finished read_reference event');

SEQUENCE_REGION:
    while ( my $row = $response->next ) {
        $logger->debug('read_seq_id event');
        $self->emit( 'read_seq_id' => $row );
        $logger->debug('write_sequence_region event');
        $self->emit(
            'write_sequence_region' => ( $self->response_id, $row ) );
    }

    $response->reset;
REFERENCE:
    while ( my $row = $response->next ) {
        $logger->debug('read_seq_id event');
        $self->emit( 'read_seq_id' => $row );
        my $seq_id = $self->response_id;
        $logger->debug('write_reference event');
        $self->emit( 'write_reference' => ( $seq_id, $row ) );
        $logger->debug('read_feature event');
        $self->emit( 'read_feature' => $row );
        next REFERENCE if !$self->has_response;
        my $rs = $self->response;
        $logger->debug('finished read_feature event');

    FEATURE:
        while ( my $frow = $rs->next ) {
            $logger->debug('write_feature event');
            $self->emit( 'write_feature' => ( $seq_id, $frow ) );
            $logger->debug('read_subfeature event');
            $self->emit( 'read_subfeature' => $frow );
            next FEATURE if !$self->has_response;

            my $rs2 = $self->response;
            $logger->debug('finished read_subfeature event');

            while ( my $sfrow = $rs2->next ) {
                $logger->debug('write_subfeature event');
                $self->emit(
                    'write_subfeature' => ( $seq_id, $frow, $sfrow ) );
            }
        }
    }
}

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::EventEmitter::Feature::Chado

=head1 VERSION

version 1.0.0

=head1 SYNOPSIS

use <MODULE NAME>;

=head1 DESCRIPTION

=head1 NAME

<MODULE NAME> - [One line description of module's purpose here]

=head1 VERSION

This document describes <MODULE NAME> version 0.0.1

=for author to fill in:
Brief code example(s) here showing commonest usage(s).
This section will be as far as many users bother reading
so make it as educational and exeplary as possible.

=for author to fill in:
Write a full description of the module and its features here.
Use subsections (=head2, =head3) as appropriate.

=head1 INTERFACE 

=for author to fill in:
Write a separate section listing the public components of the modules
interface. These normally consist of either subroutines that may be
exported, or methods that may be called on objects belonging to the
classes provided by the module.

=head2 <METHOD NAME>

=over

=item B<Use:> <Usage>

[Detail text here]

=item B<Functions:> [What id does]

[Details if neccessary]

=item B<Return:> [Return type of value]

[Details]

=item B<Args:> [Arguments passed]

[Details]

=back

=head2 <METHOD NAME>

=over

=item B<Use:> <Usage>

[Detail text here]

=item B<Functions:> [What id does]

[Details if neccessary]

=item B<Return:> [Return type of value]

[Details]

=item B<Args:> [Arguments passed]

[Details]

=back

=head1 DIAGNOSTICS

=for author to fill in:
List every single error and warning message that the module can
generate (even the ones that will "never happen"), with a full
explanation of each problem, one or more likely causes, and any
suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
A full explanation of any configuration system(s) used by the
module, including the names and locations of any configuration
files, and the meaning of any environment variables or properties
that can be set. These descriptions must also include details of any
configuration language used.

<MODULE NAME> requires no configuration files or environment variables.

=head1 DEPENDENCIES

=for author to fill in:
A list of all the other modules that this module relies upon,
  including any restrictions on versions, and an indication whether
  the module is part of the standard Perl distribution, part of the
  module's distribution, or must be installed separately. ]

  None.


  =head1 INCOMPATIBILITIES

  =for author to fill in:
  A list of any modules that this module cannot be used in conjunction
  with. This may be due to name conflicts in the interface, or
  competition for system or program resources, or due to internal
  limitations of Perl (for example, many modules that use source code
		  filters are mutually incompatible).

  None reported.


  =head1 BUGS AND LIMITATIONS

  =for author to fill in:
  A list of known problems with the module, together with some
  indication Whether they are likely to be fixed in an upcoming
  release. Also a list of restrictions on the features the module
  does provide: data types that cannot be handled, performance issues
  and the circumstances in which they may arise, practical
  limitations on the size of data sets, special cases that are not
  (yet) handled, etc.

  No bugs have been reported.Please report any bugs or feature requests to
  dictybase@northwestern.edu



  =head1 TODO

  =over

  =item *

  [Write stuff here]

  =item *

  [Write stuff here]

  =back


  =head1 AUTHOR

  I<Siddhartha Basu>  B<siddhartha-basu@northwestern.edu>


  =head1 LICENCE AND COPYRIGHT

  Copyright (c) B<2003>, Siddhartha Basu C<<siddhartha-basu@northwestern.edu>>. All rights reserved.

  This module is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself. See L<perlartistic>.


  =head1 DISCLAIMER OF WARRANTY

  BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
  FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
  OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
  PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
  EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
  ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
  YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
  NECESSARY SERVICING, REPAIR, OR CORRECTION.

  IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
  WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
  REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
  LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
  OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
  THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
		  RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
		  FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
  SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
  SUCH DAMAGES.

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

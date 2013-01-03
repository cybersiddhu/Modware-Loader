package Modware::Role::Command::WithReportLogger;
{
    $Modware::Role::Command::WithReportLogger::VERSION = '1.0.0';
}

# Other modules:
use namespace::autoclean;
use Moose::Role;
use Log::Dispatchouli;
use Time::Piece;
use POSIX qw/strftime/;

# Module implementation
#

has 'verbose' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => 0,
    documentation => 'Output logging message,default is false'
);

has 'logfile' => (
    is            => 'rw',
    isa           => 'Str',
    predicate     => 'has_logfile',
    traits        => [qw/Getopt/],
    cmd_aliases   => 'l',
    documentation => 'Name of logfile,  default goes to STDERR'
);

has 'logger' => (
    is      => 'ro',
    isa     => 'Log::Dispatchouli',
    lazy    => 1,
    traits  => [qw/NoGetopt/],
    builder => '_build_logger'
);

sub _build_logger {
    my $self = shift;
    my $options;
    $options->{ident} = $self->meta->name;
    my $logfile
        = $self->has_logfile and $self->can('logfile')
        ? $self->logfile
        : undef;
    if ($logfile) {
        my $t = Time::Piece->new;
        $options->{to_file}  = 1;
        $options->{log_file} = $logfile;
    }
    else {
        $options->{to_stderr} = 1;
    }

    my $logger = Log::Dispatchouli->new($options);
    $logger->set_prefix(
        sub {
            my ($msg) = @_;
            my $time = strftime "%m-%d-%Y %H:%M:%S", localtime;
            return sprintf "[%s]:\t%s", $time, $msg;
        }
    );
    if ( !$self->verbose ) {
        $logger->set_muted(1);
    }
    return $logger;
}

1;    # Magic true value required at end of module

__END__

=pod

=head1 NAME

Modware::Role::Command::WithReportLogger

=head1 VERSION

version 1.0.0

=head1 AUTHOR

Siddhartha Basu <biosidd@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

package PICA::Modification::Request;
#ABSTRACT: Request for modification of an identified PICA+ record

use strict;
use warnings;
use v5.10;

use parent 'PICA::Modification';
use Time::Stamp gmstamp => { format => 'easy', tz => '' };

our @ATTRIBUTES = qw(id iln epn del add request creator status updated created);

sub new {
    my $self = PICA::Modification::new( @_ );
    
	$self->{created} //= gmstamp;
    $self->{status}  //= 0;

    $self;
}

sub update {
	my ($self, $status) = @_;

	$self->{status}  = $status;
	$self->{updated} = gmstamp;
}

1;

=head1 DESCRIPTION

PICA::Modification::Request extends L<PICA::Modification> with the following
attributes:

=over 4

=item request

Unique identifier of the request.

=item creator

Optional string to identify the creator of the request.

=item status

Status of the modification requests, which is 0 for unprocessed, 1 for
applied, and -1 for rejected.

=item created

Timestamp when the modification request was created (set automatically).

=item updated

Timestamp when the modification request was last updated (set automatically).

=back

All timestamps are GMT with format C<YYYY-MM-DD HH:MM::SS>.

=method update ( $status )

Updates the status and sets the updated timestamp.

=cut

=encoding utf-8

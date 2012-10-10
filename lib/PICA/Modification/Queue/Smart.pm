package PICA::Modification::Queue::Smart;
#ABSTRACT: Queued list of modification requests with checks

use strict;
use warnings;
use v5.10.1;

use parent 'PICA::Modification::Queue';

use Carp;
use Scalar::Util qw(reftype blessed);
use PICA::Record;
use LWP::Simple ();
use Time::Stamp gmstamp => { format => 'easy', tz => '' };

sub new {
    my $class = shift;
    my %args = @_ > 1 ? @_ : %{$_[0]};

    $args{queue} = PICA::Modification::Queue->new( $args{queue} )
        unless 'PICA::Modification::Queue' ~~ reftype $args{queue};
    
    $args{check} ||= 60;

    if (($args{via} // '') =~ /^https?:\/\//) {
        $args{unapi} = $args{via};
        $args{via} = sub {
            my $id = shift;
            return eval { 
                my $url = $args{unapi} . '?format=pp&id=' . $id;
                PICA::Record->new( LWP::Simple::get( $url ) ); 
            };
        };
    }

    croak "missing 'via' parameter to retrieve PICA+ records from"
        unless 'CODE' ~~ reftype $args{via};

    bless \%args, $class;
}

sub get {
    my ($self, $id) = @_;
    my $request = $self->{queue}->get($id) || return;

    return $request if $request->{status} != 0;

    # TODO: reject on error?

    my $last = $request->{updated} || $request->{created};
    my $next = gmstamp(time()-$self->{check});

    return $request if ($next cmp $last) == -1;

    $request->update( 0 ~~ $self->pending($request) ? 1 : 0 );
    $self->{queue}->update( $id => $request );
    $self->{queue}->get($id);
}

sub request {
    my ($self,$mod) = @_;

    my $modifies = $self->pending( $mod ) // return;

    if($modifies) {
        return $self->{queue}->request($mod);
    } else {
        my $id = $self->{queue}->request($mod) || return;
        my $request = $self->{queue}->get($id) || return;
        $request->{status} = 1;
        return $self->{queue}->update( $id => $request );
    }
}

sub update { my $self = shift; $self->{queue}->update(@_); }
sub delete { my $self = shift; $self->{queue}->delete(@_); }
sub list   { my $self = shift; $self->{queue}->list(@_); }

=method pending( $modification )

Checks whether a modification or modification request is still pending.
Returns 0, 1, or undef (if the status could not be checked).

=cut

sub pending {
    my ($self, $mod) = @_;

    my $before = $self->{via}->( $mod->{id} );
    return unless blessed $before and $before->isa('PICA::Record');

    my $after = $mod->apply( $before ) || return;

    return ($before->string eq $after->string ? 0 : 1);
}

1;

=head1 SYNOPSIS

  # wrap another queue, check after one minute (60 seconds) via unAPI at $url
  my $q = PICA::Modification::Queue::Smart->new( 
      queue => $queue, check => 60, via => $url 
  );

=head1 DESCRIPTION

PICA::Modification::Queue::Smart wraps another L<PICA::Modification::Queue> and
checks pending modification whether they have been applied:

=over

=item *

New requests are rejected unless the record to be modified could be retrieved.

=item *

New request resulting in no change are automatically set to status 1 (applied).

=item *

On get it is checked whether the modification has been applied after at least
C<check> seconds.

=back

=cut

=encoding utf-8

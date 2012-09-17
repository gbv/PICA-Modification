package PICA::Modification::Queue;
#ABSTRACT: Queued list of modification requests on PICA+ records

use strict;
use warnings;
use v5.10;

use Carp;

sub new {
    my $class = shift;
    my $name  = shift || 'hash';
    
    $class = $class . '::' . ucfirst($name);

    my $file = $class;
    $file =~ s!::!/!g;
    require "$file.pm"; ## no critic

    $class->new( @_ );
}

1;

=head1 SYNOPSIS

    # Create a PICA::Modification::Queue::Hash
    my $q = PICA::Modification::Queue->new('Hash'); 

    my $id  = $q->insert( $modification );
    my $mod = $q->get( $id );
    $id     = $q->update( $id => $modification );
    $id     = $q->delete( $id );

    my @mods = $q->list( $key => $value ... );

=head1 DESCRIPTION

PICA::Modification::Queue implements a collection of modifications
(L<PICA::Modification>) or requests (L<PICA::Modification::Request>) on PICA+
records together with the CRUDL operations get, insert, update, delete, and
list. A queue may support insertion of modifications which then are stored as
modification requests.

The default implementation is a in-memory (non-persistent) hash
(L<PICA::Modification::Queue::Hash>). Additional types of queues can be
implemented in the C<PICA::Modification::Queue::> module namespace.

=method new ( $name [, %options ] )

Creates a new queue. Options are passed to the queue's constructor.

=method insert ( $modification )

Must return the id only on success.

=method get ( $id )

Returns a stored modification or undef.

=method update ( $id => $modification )

Must return the id only on success.

=method delete ( $id )

Must return the id only on success.

=method list ( %parameters )

List all or a selection of queued modifications. Parameters can be used for
selection.  Special parameters are: C<page>, C<pagesize>, and C<sort>.

=cut

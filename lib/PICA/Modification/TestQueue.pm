package PICA::Modification::TestQueue;
#ABSTRACT: Unit test implementations of PICA::Modification::Queue

use strict;
use warnings;
use v5.10;

use Test::More 0.96;
use PICA::Modification;
use Test::JSON::Entails;

use parent 'Exporter';
our @EXPORT = qw(test_queue);

sub test_queue {
	my $queue = shift;
    my $name  = shift;

	subtest $name => sub {
	    my $test = bless { queue => $queue }, __PACKAGE__;
        $test->run;
    };
}

sub get { my $t = shift; $t->{queue}->get(@_); }
sub insert { my $t = shift; $t->{queue}->insert(@_); }
sub update { my $t = shift; $t->{queue}->update(@_); }
sub delete { my $t = shift; $t->{queue}->delete(@_); }
sub list { my $t = shift; $t->{queue}->list(@_); }

sub run {
	my $self = shift;

	my $list = $self->list();
	is_deeply $list, [], 'empty queue';

	my $mod = PICA::Modification->new( 
		del => '012A',
		id  => 'foo:ppn:123',
	);

	my $id = $self->insert( $mod );
	ok( $id, "inserted modification" );

	my $got = $self->get($id);
	entails $got => $mod->attributes, 'get stored modification';

	$list = $self->list();
	is scalar @$list, 1, 'list size 1';
	entails $list->[0] => $mod->attributes, 'list contains modification';

    $mod = PICA::Modification->new( del => '012A', id => 'bar:ppn:123' );
    my $id2 = $self->insert( $mod );
	$list = $self->list( sort => 'id' );
	is scalar @$list, 2, 'list size 2';
    is $list->[0]->{id}, 'bar:ppn:123', 'sorted list';

	$list = $self->list( id => 'foo:ppn:123' );
	is scalar @$list, 1, 'search by field value';
    is $list->[0]->{id}, 'foo:ppn:123', 'only list matching modifications';

    foreach (0..4) {
        $mod = PICA::Modification->new( del => '012A', id => "doz:ppn:$_" );
        $self->insert($mod);
    }
    $list = $self->list( sort => 'id', pagesize => 3 );
    is scalar @$list, 3, 'pagesize';

    $list = $self->list( sort => 'id', pagesize => 3, page => 2 );
    is scalar @$list, 3, 'pagesize';
    is $list->[0]->{id}, 'doz:ppn:2', 'page';

    $mod = PICA::Modification->new( add => '028A $xfoo' );
    $id2 = $self->update( $id => $mod );
    is $id2, $id, 'update allowed';
    $mod = $self->get($id);
    is $mod->{del}, '', 'update changed';
    is $mod->{add}, '028A $xfoo', 'update changed';

	my $delid = $self->delete($id);
	is $delid, $id, 'deleted modification';

	$got = $self->get($id);
	is $got, undef, 'deleted modification returns undef';
}

1;

=head1 SYNOPSIS

    use PICA::Modification::TestQueue;

    test_queue $queue, 'tested queue';

=head1 DESCRIPTION

This package exports the function C<test_queue> to run a simple unit test on a
L<PICA::Modification::Queue>.

=cut
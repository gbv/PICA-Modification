package PICA::Modification::Queue::Hash;
#ABSTRACT: In-memory collection of modifications

use strict;
use warnings;
use v5.10;

sub new { 
    bless [{},0], shift; 
}

sub get {
   my ($self, $id) = @_;
   return $self->[0]->{ $id };
}

sub insert {
	my ($self, $object) = @_;
	return unless defined $object;
	my $id = ++$self->[1];
	$self->[0]->{ $id } = $object;
	return $id;
}

sub update { 
    my ($self, $id => $object) = @_;
    return unless defined $self->[0]->{ $id };
	$self->[0]->{ $id } = $object;
	return $id;
}

sub delete {
    my ($self, $id) = @_;
    return unless defined $self->[0]->{ $id };
	delete $self->[0]->{ $id }; 
	$id;
}

sub list {
	my ($self, %properties) = @_;

	my $pagesize = delete $properties{pagesize} || 20;
	my $page     = delete $properties{page} || 1;
	my $sortby   = delete $properties{sort};

	my $hash = $self->[0];

    my $c = 0;
    my $grep = sub {
        while (my ($k,$v) = each(%properties)) {
            return 0 unless $_[0]->{$k} eq $v; 
        }
        $c++;
        return 0 if $c > $page*$pagesize;
        return 0 if $c <= ($page-1)*$pagesize;
        1;
    };

    if ( $sortby ) {
        my $sort = sub { $a->{$sortby} cmp $b->{$sortby} };
        return [ grep { $grep->($_) } sort $sort values %$hash ];
    } else {
        return [ grep { $grep->($_) } values %$hash ];
    }
}

1;

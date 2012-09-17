use strict;
use warnings;
use Test::More;

use PICA::Record;
use PICA::Modification;

sub picamod { PICA::Modification->new(@_); }

my @ok = (
 { },
 { id => 'opac-de-23:ppn:311337856' },
 { id => '' },
);
for (my $i=0; $i<$#ok; $i++) {
	my $mod = picamod( %{ $ok[$i] } );
	ok( !$mod->error, "ok ".($i+1));
}

my @malformed = (
	[ {	add => '144Z $a' }, { add => 'malformed fields to add' } ], 
	[ {	del => '144Z $a' }, { del => 'malformed fields to remove', iln => 'missing ILN for remove'} ], 
	[ { add => '144Z $afoo' }, { iln => 'missing ILN for add' } ],
	[ { del => '144Z' }, { iln => 'missing ILN for remove' } ],
	[ { add => '209@ $fbar' }, { epn => 'missing EPN for add' } ],
	[ { del => '209@' }, { epn => 'missing EPN for remove' } ],
	[ { del => '201A', iln => 'abc', epn => 'xyz' }, { iln => 'malformed ILN', epn => 'malformed EPN' } ],
	[ { id => 'ab:cd' }, { id => 'malformed record identifier' } ],
);

foreach (@malformed) {
	my ($fields,$errors) = @$_;
	my $mod = picamod( %$fields );
	is( $mod->error, scalar (keys %$errors) );
	while (my ($f,$msg) = each %$errors) {
		is( $mod->error($f), $msg, $msg );
	}
}

done_testing;

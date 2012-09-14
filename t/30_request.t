use strict;
use warnings;
use Test::More;

use PICA::Modification::Request;

my $req = PICA::Modification::Request->new(
	id => 'foo:ppn:789',
	del => '012A'
);

is $req->{status}, 0, 'status 0 by default';
like $req->{created}, qr{^\d{4}-\d\d-\d\d \d\d:\d\d:\d\d$}, 'timestamp';

$req->update(-1);
is $req->{status}, -1, 'status updated';
like $req->{updated}, qr{^\d{4}-\d\d-\d\d \d\d:\d\d:\d\d$}, 'timestamp';

done_testing;

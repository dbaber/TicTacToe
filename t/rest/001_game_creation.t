use strict;
use warnings;

use Test::More tests => 2;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use JSON;

use TicTacToe::Test;

TicTacToe::Test::prepare_db();

my $app  = TicTacToe::Test::get_psgi_app();
my $test = Plack::Test->create($app);

my $request  = GET '/api/game';
my $response = $test->request($request);
is $response->code, 200, "Get availble games is working";
my $decoded = from_json( $response->content );
is scalar( @{$decoded} ), 0, "No available games to join";

1;

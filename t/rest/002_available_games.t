use strict;
use warnings;

use Test::More tests => 24;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use JSON;

use TicTacToe::Test qw(prepare_db get_psgi_app);

prepare_db();

my $app  = get_psgi_app();
my $test = Plack::Test->create($app);

# No available games to join initially
no_avavailable_games_initially: {
	my $request  = GET '/api/game';
	my $response = $test->request($request);
	is( $response->code, 200, "Get availble games is working" );
	my $decoded = from_json( $response->content );
	is( scalar( @{$decoded} ), 0, "... and there are no available games to join initially" );
}

# Create available games and list them
create_available_games_and_list_them: {
	my $request = POST '/api/game',
	  Content_Type => 'application/json',
	  Content      => to_json(
		{
			player1 => {
				player_name => 'Dan',
				player_mark => 'X',
			},
			goes_first => 'X',
		}
	  );

	my $response = $test->request($request);
	is( $response->code, 201, "Created a game as 'Dan' using 'X' and choosing to go first" );

	$request = POST '/api/game',
	  Content_Type => 'application/json',
	  Content      => to_json(
		{
			player1 => {
				player_name => 'Ben',
				player_mark => 'O',
			},
			goes_first => 'X',
		}
	  );

	$response = $test->request($request);
	is( $response->code, 201, "Created a game as 'Ben' using 'O' and choosing to go second" );

	$request  = GET '/api/game';
	$response = $test->request($request);
	is( $response->code, 200, "Got available games" );

	my $decoded = from_json( $response->content );
	is( scalar( @{$decoded} ), 2, "... and there are 2 available games to join" );

	my $game1 = $decoded->[0];
	isnt( $game1->{game_id}, undef, "Checking first available game" );
	is( $game1->{player1}{player_name}, 'Dan', "... and player1's name is 'Dan'" );
	is( $game1->{player1}{player_mark}, 'X',   "... and player1's mark is 'X'" );
	ok( $game1->{player1}{player_code} eq $game1->{current_player}{player_code},
		"... and player1 or 'X' is going first" );
	is( $game1->{game_status_value}, 'waiting', "... and the game is in the 'waiting' status" );
	is( $game1->{player2_id},        undef,     "... and player2 has not joined the game" );
	isnt( $game1->{game_auth_code}, undef, "... and the game auth code was set" );
	is( $game1->{game_board}, '[1,2,3,4,5,6,7,8,9]', "... and the game board was initialized" );
	is( $game1->{winning_player_id}, undef, "... and there is no winner" );

	my $game2 = $decoded->[1];
	isnt( $game1->{game_id}, undef, "Checking second available game" );
	is( $game2->{player1}{player_name}, 'Ben',     "... and player1's name is 'Ben'" );
	is( $game2->{player1}{player_mark}, 'O',       "... and player1's mark is 'O'" );
	is( $game2->{current_player_id},    undef,     "... and player2 or 'X' is going first" );
	is( $game2->{game_status_value},    'waiting', "... and the game is in the 'waiting' status" );
	is( $game2->{player2_id},           undef,     "... and player2 has not joined the game" );
	isnt( $game2->{game_auth_code}, undef, "... and the game auth code was set" );
	is( $game2->{game_board}, '[1,2,3,4,5,6,7,8,9]', "... and the game board was initialized" );
	is( $game2->{winning_player_id}, undef, "... and there is no winner" );
}

1;

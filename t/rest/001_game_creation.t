use strict;
use warnings;

use Test::More tests => 40;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use JSON;

use TicTacToe::Test;

TicTacToe::Test::prepare_db();

my $app  = TicTacToe::Test::get_psgi_app();
my $test = Plack::Test->create($app);

# Create a game as 'X' and choose 'X' to go first
create_game_as_x_choose_x_to_go_first: {
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
	is( $response->code, 201, "Created a game as 'X' and chose 'X' to go first" );

	my $decoded = from_json( $response->content );
	like( $response->header('Location'), qr{/api/game/$decoded->{game_id}}, "...and Location header is set" );
	is( $decoded->{player1}{player_name}, 'Dan', "... and player1's name is 'Dan'" );
	is( $decoded->{player1}{player_mark}, 'X',   "... and player1's mark is 'X'" );
	ok( $decoded->{player1}{player_code} eq $decoded->{current_player}{player_code},
		"... and player1 or 'X' is going first" );
	is( $decoded->{game_status_value}, 'waiting', "... and the game is in the 'waiting' status" );
	is( $decoded->{player2_id},        undef,     "... and player2 has not joined the game" );
	isnt( $decoded->{game_auth_code}, undef, "... and the game auth code was set" );
	is( $decoded->{game_board}, '[1,2,3,4,5,6,7,8,9]', "... and the game board was initialized" );
	is( $decoded->{winning_player_id}, undef, "... and there is no winner" );
}

# Create a game as 'X' and choose 'O' to go first
create_game_as_x_choose_o_to_go_first: {
	my $request = POST '/api/game',
	  Content_Type => 'application/json',
	  Content      => to_json(
		{
			player1 => {
				player_name => 'Dan',
				player_mark => 'X',
			},
			goes_first => 'O',
		}
	  );

	my $response = $test->request($request);
	is( $response->code, 201, "Created a game as 'X' and chose 'O' to go first" );

	my $decoded = from_json( $response->content );
	like( $response->header('Location'), qr{/api/game/$decoded->{game_id}}, "...and Location header is set" );
	is( $decoded->{player1}{player_name}, 'Dan',     "... and player1's name is 'Dan'" );
	is( $decoded->{player1}{player_mark}, 'X',       "... and player1's mark is 'X'" );
	is( $decoded->{current_player_id},    undef,     "... and player2 or 'O' is going first" );
	is( $decoded->{game_status_value},    'waiting', "... and the game is in the 'waiting' status" );
	is( $decoded->{player2_id},           undef,     "... and player2 has not joined the game" );
	isnt( $decoded->{game_auth_code}, undef, "... and the game auth code was set" );
	is( $decoded->{game_board}, '[1,2,3,4,5,6,7,8,9]', "... and the game board was initialized" );
	is( $decoded->{winning_player_id}, undef, "... and there is no winner" );
}

# Create a game as 'O' and choose 'O' to go first
create_game_as_o_choose_o_to_go_first: {
	my $request = POST '/api/game',
	  Content_Type => 'application/json',
	  Content      => to_json(
		{
			player1 => {
				player_name => 'Dan',
				player_mark => 'O',
			},
			goes_first => 'O',
		}
	  );

	my $response = $test->request($request);
	is( $response->code, 201, "Created a game as 'O' and chose 'O' to go first" );

	my $decoded = from_json( $response->content );
	like( $response->header('Location'), qr{/api/game/$decoded->{game_id}}, "...and Location header is set" );
	is( $decoded->{player1}{player_name}, 'Dan', "... and player1's name is 'Dan'" );
	is( $decoded->{player1}{player_mark}, 'O',   "... and player1's mark is 'O'" );
	ok( $decoded->{player1}{player_code} eq $decoded->{current_player}{player_code},
		"... and player1 or 'O' is going first" );
	is( $decoded->{game_status_value}, 'waiting', "... and the game is in the 'waiting' status" );
	is( $decoded->{player2_id},        undef,     "... and player2 has not joined the game" );
	isnt( $decoded->{game_auth_code}, undef, "... and the game auth code was set" );
	is( $decoded->{game_board}, '[1,2,3,4,5,6,7,8,9]', "... and the game board was initialized" );
	is( $decoded->{winning_player_id}, undef, "... and there is no winner" );
}

# Create a game as 'O' and choose 'X' to go first
create_game_as_o_choose_x_to_go_first: {
	my $request = POST '/api/game',
	  Content_Type => 'application/json',
	  Content      => to_json(
		{
			player1 => {
				player_name => 'Dan',
				player_mark => 'O',
			},
			goes_first => 'X',
		}
	  );

	my $response = $test->request($request);
	is( $response->code, 201, "Created a game as 'O' and chose 'X' to go first" );

	my $decoded = from_json( $response->content );
	like( $response->header('Location'), qr{/api/game/$decoded->{game_id}}, "...and Location header is set" );
	is( $decoded->{player1}{player_name}, 'Dan',     "... and player1's name is 'Dan'" );
	is( $decoded->{player1}{player_mark}, 'O',       "... and player1's mark is 'O'" );
	is( $decoded->{current_player_id},    undef,     "... and player2 or 'X' is going first" );
	is( $decoded->{game_status_value},    'waiting', "... and the game is in the 'waiting' status" );
	is( $decoded->{player2_id},           undef,     "... and player2 has not joined the game" );
	isnt( $decoded->{game_auth_code}, undef, "... and the game auth code was set" );
	is( $decoded->{game_board}, '[1,2,3,4,5,6,7,8,9]', "... and the game board was initialized" );
	is( $decoded->{winning_player_id}, undef, "... and there is no winner" );
}

1;

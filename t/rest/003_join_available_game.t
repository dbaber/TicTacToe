use strict;
use warnings;

use Test::More tests => 19;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use JSON;

use TicTacToe::Test;

TicTacToe::Test::prepare_db();

my $app  = TicTacToe::Test::get_psgi_app();
my $test = Plack::Test->create($app);

# Invalid game auth code fails
invalid_game_auth_code_fails: {
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

	my $decoded                = from_json( $response->content );
	my $game_id                = $decoded->{game_id};
	my $game_auth_code         = $decoded->{game_auth_code};
	my $invalid_game_auth_code = substr( $game_auth_code, 0, -1 );

	$request = POST "/api/game/$game_id/join",
	  Content_Type => 'application/json',
	  Content      => to_json(
		{
			player2 => {
				player_name => 'Dan',

			},
			game_auth_code => $invalid_game_auth_code,
		}
	  );

	$response = $test->request($request);
	is( $response->code, 400, "... and joining the game with an invalid auth code fails" );
	$decoded = from_json( $response->content );
	is_deeply(
		$decoded,
		{
			message => "Invalid game authorization code.",
			status  => 400,
			title   => "Error 400 - Bad Request",
		},
		"... and we got the expected error structure"
	);
}

cannot_join_running_game: {
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

	my $decoded        = from_json( $response->content );
	my $game_id        = $decoded->{game_id};
	my $game_auth_code = $decoded->{game_auth_code};

	$request = POST "/api/game/$game_id/join",
	  Content_Type => 'application/json',
	  Content      => to_json(
		{
			player2 => {
				player_name => 'Ben',

			},
			game_auth_code => $game_auth_code,
		}
	  );

	$response = $test->request($request);
	is( $response->code, 201, "... joining the game as 'Ben' works" );

	$request = POST "/api/game/$game_id/join",
	  Content_Type => 'application/json',
	  Content      => to_json(
		{
			player2 => {
				player_name => 'Ben',

			},
			game_auth_code => $game_auth_code,
		}
	  );

	$response = $test->request($request);
	is( $response->code, 400, "... and joining a running game fails" );
	$decoded = from_json( $response->content );
	is_deeply(
		$decoded,
		{
			message => "Can only join a waiting available game.",
			status  => 400,
			title   => "Error 400 - Bad Request",
		},
		"... and we got the expected error structure"
	);
}

join_an_available_game: {
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

	my $decoded        = from_json( $response->content );
	my $game_id        = $decoded->{game_id};
	my $game_auth_code = $decoded->{game_auth_code};

	$request = POST "/api/game/$game_id/join",
	  Content_Type => 'application/json',
	  Content      => to_json(
		{
			player2 => {
				player_name => 'Ben',

			},
			game_auth_code => $game_auth_code,
		}
	  );

	$response = $test->request($request);
	is( $response->code, 201, "... joining the game as 'Ben' works" );

	$decoded = from_json( $response->content );
	like( $response->header('Location'), qr{/api/game/$decoded->{game_id}}, "...and Location header is set" );
	is( $decoded->{player1}{player_name}, 'Dan', "... and player1's name is 'Dan'" );
	is( $decoded->{player1}{player_mark}, 'X',   "... and player1's mark is 'X'" );
	is( $decoded->{player2}{player_name}, 'Ben', "... and player2's name is 'Ben'" );
	is( $decoded->{player2}{player_mark}, 'O',   "... and player2's mark is 'O'" );
	ok( $decoded->{player1}{player_code} eq $decoded->{current_player}{player_code},
		"... and player1 or 'X' is going first" );
	is( $decoded->{game_status_value}, 'running', "... and the game is in the 'running' status" );
	isnt( $decoded->{game_auth_code}, undef, "... and the game auth code was set" );
	is( $decoded->{game_board}, '[1,2,3,4,5,6,7,8,9]', "... and the game board was initialized" );
	is( $decoded->{winning_player_id}, undef, "... and there is no winner" );
}

1;

use strict;
use warnings;

use Test::More tests => 27;
use Plack::Test;
use HTTP::Request::Common;
use JSON;

use TicTacToe::Test qw(prepare_db get_psgi_app);

prepare_db();

my $app  = get_psgi_app();
my $test = Plack::Test->create($app);

game_not_found: {
	my $request  = GET '/api/game/1';
	my $response = $test->request($request);
	is( $response->code, 404, "Game not found" );
	my $decoded = from_json( $response->content );
	is_deeply(
		$decoded,
		{
			message => "Game not found for id '1'.",
			status  => 404,
			title   => "Error 404 - Not Found",
		},
		"... and we got the expected error structure"
	);
}

not_authorized_to_view_game: {
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

	$request  = GET $response->header('location');
	$response = $test->request($request);
	is( $response->code, 401, "... and fetching the game without proper access codes fails" );
	my $decoded = from_json( $response->content );
	is_deeply(
		$decoded,
		{
			message => "You are not authorized to access this game.",
			status  => 401,
			title   => "Error 401 - Unauthorized",
		},
		"... and we got the expected error structure"
	);
}

# Get a 'waiting' game
get_a_waiting_game: {
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
	my $user_code      = $decoded->{player1}{player_code};
	my $game_auth_code = $decoded->{game_auth_code};

	$request = GET $response->header('Location'),
	  X_User_Code      => $user_code,
	  X_Game_Auth_Code => $game_auth_code;
	$response = $test->request($request);
	is( $response->code, 200, "Got waiting available game" );

	$decoded = from_json( $response->content );
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

# Get a 'running' game
get_a_running_game: {
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
	is( $response->code, 201, "Joining the game as 'Ben' works" );
	$decoded = from_json( $response->content );
	my $user_code = $decoded->{player1}{player_code};
	$game_auth_code = $decoded->{game_auth_code};

	$request = GET $response->header('Location'),
	  X_User_Code      => $user_code,
	  X_Game_Auth_Code => $game_auth_code;
	$response = $test->request($request);
	is( $response->code, 200, "Got running game" );

	$decoded = from_json( $response->content );
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


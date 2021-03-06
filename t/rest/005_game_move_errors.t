use strict;
use warnings;

use Test::More tests => 39;
use Plack::Test;
use HTTP::Request::Common;
use JSON;

use TicTacToe::Test qw(
  prepare_db
  get_psgi_app
);

use TicTacToe::Test::Utils qw(
  create_waiting_game
  create_running_game
  make_game_move
  make_game_moves
);

prepare_db();

my $app  = get_psgi_app();
my $test = Plack::Test->create($app);

game_not_found_for_move: {
	my $request  = POST '/api/game/1/move/1';
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

not_authorized_to_make_move: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $game_id        = $game->{game_id};
	my $player1_code   = $game->{player1}{player_code};
	my $game_auth_code = $game->{game_auth_code};
	my $request        = POST "/api/game/$game_id/move/1",
	  Content_Type => 'application/json',
	  Content      => to_json(
		{
			player_code    => substr( $player1_code,   0, -1 ),
			game_auth_code => substr( $game_auth_code, 0, -1 ),
		}
	  );

	my $response = $test->request($request);
	is( $response->code, 401, "Not authorized to make move without correct player and game codes" );

	my $decoded = from_json( $response->content );
	is_deeply(
		$decoded,
		{
			message => "You are not authorized to make a move on this game board.",
			status  => 401,
			title   => "Error 401 - Unauthorized",
		},
		"... and we got the expected error structure"
	);
}

cannot_make_move_on_game_not_running_waiting: {
	my $game = create_waiting_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $game_id        = $game->{game_id};
	my $player1_code   = $game->{player1}{player_code};
	my $game_auth_code = $game->{game_auth_code};
	my $request        = POST "/api/game/$game_id/move/1",
	  Content_Type => 'application/json',
	  Content      => to_json(
		{
			player_code    => $player1_code,
			game_auth_code => $game_auth_code,
		}
	  );

	my $response = $test->request($request);
	is( $response->code, 400, "Cannot make a move on a game not running" );

	my $decoded = from_json( $response->content );
	is_deeply(
		$decoded,
		{
			message => "Cannot make a move on a game that is not running.",
			status  => 400,
			title   => "Error 400 - Bad Request",
		},
		"... and we got the expected error structure"
	);
}

cannot_move_out_of_turn: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $game_id        = $game->{game_id};
	my $player2_code   = $game->{player2}{player_code};
	my $game_auth_code = $game->{game_auth_code};
	my $request        = POST "/api/game/$game_id/move/1",
	  Content_Type => 'application/json',
	  Content      => to_json(
		{
			player_code    => $player2_code,
			game_auth_code => $game_auth_code,
		}
	  );

	my $response = $test->request($request);
	is( $response->code, 400, "Cannot move out of turn" );

	my $decoded = from_json( $response->content );
	is_deeply(
		$decoded,
		{
			message => "Player2 cannot move out of turn.",
			status  => 400,
			title   => "Error 400 - Bad Request",
		},
		"... and we got the expected error structure"
	);
}

cannot_move_to_invalid_index: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $response = make_game_move(
		test   => $test,
		game   => $game,
		symbol => 'X',
		index  => 0,
	);

	is( $response->code, 400, "Cannot move to invalid index '0'" );

	my $decoded = from_json( $response->content );
	is_deeply(
		$decoded,
		{
			message => "Cannot move to index '0' because it is invalid.",
			status  => 400,
			title   => "Error 400 - Bad Request",
		},
		"... and we got the expected error structure"
	);

	$response = make_game_move(
		test   => $test,
		game   => $game,
		symbol => 'X',
		index  => 10,
	);

	is( $response->code, 400, "Cannot move to invalid index '10'" );

	$decoded = from_json( $response->content );
	is_deeply(
		$decoded,
		{
			message => "Cannot move to index '10' because it is invalid.",
			status  => 400,
			title   => "Error 400 - Bad Request",
		},
		"... and we got the expected error structure"
	);
}

cannot_move_to_occupied_index: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $response = make_game_move(
		test   => $test,
		game   => $game,
		symbol => 'X',
		index  => 1,
	);

	is( $response->code, 201, "Player1 placed an 'X' on index '1'." );

	$response = make_game_move(
		test   => $test,
		game   => $game,
		symbol => 'O',
		index  => 1,
	);

	my $decoded = from_json( $response->content );
	is( $response->code, 400, "... and player2 cannot move to already occupied index '1'" );

	$decoded = from_json( $response->content );
	is_deeply(
		$decoded,
		{
			message => "Cannot move to index '1' because it is already occupied.",
			status  => 400,
			title   => "Error 400 - Bad Request",
		},
		"... and we got the expected error structure"
	);
}

# Diagonal win for 'X'
#
# Board
# =====
# X 2 X
# 4 X O
# O O X
#
# String: '[X,2,X,4,X,O,O,O,X]'
#
# Moves: 5X,7O,3X,8O,9X,6O,1X
cannot_move_on_game_that_is_won_not_running: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/5X 7O 3X 8O 9X 6O 1X/],
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 7 ], "Created game where player1 or 'X' wins" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	like( $response->header('Location'), qr{/api/game/$decoded->{game_id}}, "...and Location header is set" );
	is( $decoded->{player1}{player_name}, 'Dan', "... and player1's name is 'Dan'" );
	is( $decoded->{player1}{player_mark}, 'X',   "... and player1's mark is 'X'" );
	is( $decoded->{player2}{player_name}, 'Ben', "... and player2's name is 'Ben'" );
	is( $decoded->{player2}{player_mark}, 'O',   "... and player2's mark is 'O'" );
	ok(
		$decoded->{player1}{player_code} eq $decoded->{current_player}{player_code},
		"... and player1 or 'X' should be the current_player since the game is over/won"
	);
	is( $decoded->{game_status_value}, 'complete', "... and the game is in the 'complete' status" );
	isnt( $decoded->{game_auth_code}, undef, "... and the game auth code was set" );
	is( $decoded->{game_board},        '[X,2,X,4,X,O,O,O,X]',  "... and the game board has diagonal win for 'X'" );
	is( $decoded->{winning_player_id}, $decoded->{player1_id}, "... and player1 is the winner" );

	$response = make_game_move(
		test   => $test,
		game   => $game,
		symbol => 'O',
		index  => 2,
	);

	$decoded = from_json( $response->content );
	is( $response->code, 400, "Cannot make a move on game that is won" );

	$decoded = from_json( $response->content );
	is_deeply(
		$decoded,
		{
			message => "Cannot make a move on a game that is not running.",
			status  => 400,
			title   => "Error 400 - Bad Request",
		},
		"... and we got the expected error structure"
	);
}

1;

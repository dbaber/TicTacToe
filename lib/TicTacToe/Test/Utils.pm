package TicTacToe::Test::Utils;

use strict;
use warnings;

use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use JSON;

use Sub::Exporter -setup => {
	exports => [
		qw/
		  create_waiting_game
		  create_running_game
		  make_game_move
		  make_game_moves
		  check_game
		  /
	],
};

sub create_waiting_game {
	my %opts = @_;
	my $test = $opts{test};

	my $request = POST '/api/game',
	  Content_Type => 'application/json',
	  Content      => to_json(
		{
			player1 => {
				player_name => $opts{player1_name},
				player_mark => $opts{player1_mark},
			},
			goes_first => $opts{goes_first},
		}
	  );

	my $response = $test->request($request);
	is( $response->code, 201,
		"Created a game as '$opts{player1_name}' using '$opts{player1_mark}' with '$opts{goes_first}' going first" );

	my $decoded = from_json( $response->content );

	return $decoded;
}

sub create_running_game {
	my %opts = @_;
	my $test = $opts{test};

	my $request = POST '/api/game',
	  Content_Type => 'application/json',
	  Content      => to_json(
		{
			player1 => {
				player_name => $opts{player1_name},
				player_mark => $opts{player1_mark},
			},
			goes_first => $opts{goes_first},
		}
	  );

	my $response = $test->request($request);
	is( $response->code, 201,
		"Created a game as '$opts{player1_name}' using '$opts{player1_mark}' with '$opts{goes_first}' going first" );

	my $decoded        = from_json( $response->content );
	my $game_id        = $decoded->{game_id};
	my $game_auth_code = $decoded->{game_auth_code};

	$request = POST "/api/game/$game_id/join",
	  Content_Type => 'application/json',
	  Content      => to_json(
		{
			player2 => {
				player_name => $opts{player2_name},

			},
			game_auth_code => $game_auth_code,
		}
	  );

	$response = $test->request($request);
	is( $response->code, 201, "Joining the game as '$opts{player2_name}' works" );

	$decoded = from_json( $response->content );

	return $decoded;
}

sub get_player_by_symbol {
	my ( $game, $symbol ) = @_;

	return ( $game->{player1}{player_mark} eq $symbol )
	  ? ( $game->{player1} )
	  : ( $game->{player2} );
}

sub make_game_move {
	my %opts = @_;
	my $test = $opts{test};

	my $game   = $opts{game};
	my $symbol = $opts{symbol};
	my $index  = $opts{index};

	my $game_id        = $game->{game_id};
	my $player         = get_player_by_symbol( $game, $symbol );
	my $player_code    = $player->{player_code};
	my $game_auth_code = $game->{game_auth_code};
	my $request        = POST "/api/game/$game_id/move/$index",
	  Content_Type => 'application/json',
	  Content      => to_json(
		{
			player_code    => $player_code,
			game_auth_code => $game_auth_code,
		}
	  );

	my $response = $test->request($request);

	return $response;
}

sub make_game_moves {
	my %opts = @_;
	my $test = $opts{test};

	my $game  = $opts{game};
	my $moves = $opts{moves};

	my @responses = ();

	for my $move (@$moves) {
		my ( $index, $symbol ) = ( $move =~ /^(\d)([X|O])$/ );
		push @responses,
		  make_game_move(
			test   => $test,
			game   => $game,
			symbol => $symbol,
			index  => $index,
		  );
	}

	return \@responses;
}

sub check_game {
	my %opts = @_;

	my $response            = $opts{response};
	my $game                = $opts{game};
	my $player1_name        = $opts{player1_name};
	my $player1_mark        = $opts{player1_mark};
	my $player2_name        = $opts{player2_name};
	my $player2_mark        = $opts{player2_mark};
	my $current_player      = $opts{current_player};
	my $current_player_mark = $game->{current_player}{player_mark};
	my $game_status         = $opts{game_status};
	my $game_board          = $opts{game_board};
	my $winning_player_id   = $opts{winning_player_id};
	my $winning_player      = $opts{winning_player};

	like( $response->header('Location'), qr{/api/game/$game->{game_id}}, "...and Location header is set" );
	is( $game->{player1}{player_name}, $player1_name, "... and player1's name is 'Dan'" );
	is( $game->{player1}{player_mark}, $player1_mark, "... and player1's mark is 'X'" );
	is( $game->{player2}{player_name}, $player2_name, "... and player2's name is 'Ben'" );
	is( $game->{player2}{player_mark}, $player2_mark, "... and player2's mark is 'O'" );
	ok( $game->{$current_player}{player_code} eq $game->{current_player}{player_code},
		"... and $current_player or '$current_player_mark' should be the current_player since the game is over" );
	is( $game->{game_status_value}, 'complete', "... and the game is in the 'complete' status" );
	isnt( $game->{game_auth_code}, undef, "... and the game auth code was set" );
	is( $game->{game_board}, $game_board, "... and the game board is in the expected state" );

	if ( defined $game->{winning_player_id} ) {
		is( $game->{winning_player_id}, $game->{ $winning_player . '_id' }, "... and $winning_player is the winner" );
	}
	else {
		is( $game->{winning_player_id}, undef, "... and there is no winner" );
	}

	return;
}

1;

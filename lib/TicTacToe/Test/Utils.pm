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

	my $game  = $opts{game};
	my $moves = $opts{moves};

	my @responses = ();

	for my $move (@$moves) {
		my ( $index, $symbol ) = ( $move =~ /^(\d)([X|O])$/ );
		push @responses,
		  make_game_move(
			game   => $game,
			symbol => $symbol,
			index  => $index,
		  );
	}

	return \@responses;
}

1;

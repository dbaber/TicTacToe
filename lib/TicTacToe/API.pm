package TicTacToe::API;

use Dancer2;
use Dancer2::Plugin::DBIC;

use Game::TicTacToe;
use Game::TicTacToe::Board;
use Game::TicTacToe::Player;
use Game::TicTacToe::Move;

set serializer => 'JSON';

post '/game' => sub {

	# TODO: Params validation?
	my $player1    = body_parameters->get('player1');
	my $goes_first = body_parameters->get('goes_first');

	my $game = Game::TicTacToe->new();
	$game->add_player1( $player1->{player_name}, $player1->{player_mark}, $goes_first );

	my $game_r = schema->resultset('Game')->new_result( {} )->save( $game->db_data() );

	status 201;
	header 'Location' => uri_for( '/game/' . $game_r->game_id );
	return $game_r->rest_data();
};

get '/game' => sub {
	my $game_rs = schema->resultset('Game')->search(
		{
			game_status_value => 'waiting',

		},
		{
			prefetch => [
				qw/
				  player1
				  player2
				  current_player
				  winning_player
				  /,
			],
		}
	);

	my @data = map { $_->rest_data() } $game_rs->all;

	return \@data;
};

#XXX: Coul probably use a type coercion but punting on that
sub _convert_board {
	my ($board) = @_;

	$board =~ s/^\[//;
	$board =~ s/\]$//;

	my @board = split /,/, $board;

	return \@board;
}

post '/game/:id/join' => sub {

	# TODO: Params validation?
	my $id             = route_parameters->get('id');
	my $player2        = body_parameters->get('player2');
	my $game_auth_code = body_parameters->get('game_auth_code');

	my $game_r = schema->resultset('Game')->find($id);

	send_error( "Invalid game authorization code.", 400 ) if $game_r->game_auth_code ne $game_auth_code;
	send_error( "Can only join a waiting available game.", 400 )
	  unless $game_r->game_status_value eq 'waiting';

	my $current_player = $game_r->current_player;
	my $player1        = $game_r->player1;
	my $game           = Game::TicTacToe->new(
		is_public => $game_r->is_public,
		board     => Game::TicTacToe::Board->new( cell => _convert_board( $game_r->game_board ) ),
		(
			defined $current_player
			? (
				current => Game::TicTacToe::Player->new(
					name   => $current_player->player_name,
					type   => 'H',
					symbol => $current_player->player_mark,
					code   => $current_player->player_code,
				)
			  )
			: ()
		),
		players => [
			Game::TicTacToe::Player->new(
				name   => $player1->player_name,
				type   => 'H',
				symbol => $player1->player_mark,
				code   => $player1->player_code,
			),
		],
		status    => $game_r->game_status_value,
		auth_code => $game_r->game_auth_code,
	);

	$game->join_player2( $player2->{player_name} );

	$game_r->save( $game->db_data() );

	status 201;
	header 'Location' => uri_for( '/game/' . $game_r->game_id );
	return $game_r->rest_data();
};

get '/game/:id' => sub {
	my $x_user_code      = request_header 'X-User-Code';
	my $x_game_auth_code = request_header 'X-Game-Auth-Code';

	# TODO: Params validation?
	my $id = route_parameters->get('id');

	my $game_r = schema->resultset('Game')->find($id);
	if ( !defined $game_r ) {
		send_error( "Game not found for id '$id'.", 404 );
	}

	send_error( "You are not authorized to access this game.", 401 )
	  unless ( $game_r->game_auth_code eq $x_game_auth_code
		&& ( $game_r->player1->player_code eq $x_user_code || $game_r->player2->player_code eq $x_user_code ) );

	return $game_r->rest_data();
};

post '/game/:id/move/:index' => sub {

	# TODO: Params validation?
	my $id             = route_parameters->get('id');
	my $index          = route_parameters->get('index');
	my $player_code    = body_parameters->get('player_code');
	my $game_auth_code = body_parameters->get('game_auth_code');

	my $game_r = schema->resultset('Game')->find($id);
	if ( !defined $game_r ) {
		send_error( "Game not found for id '$id'.", 404 );
	}

	send_error( "You are not authorized to make a move on this game board.", 401 )
	  unless (
		$game_r->game_auth_code eq $game_auth_code
		&& (   $game_r->player1->player_code eq $player_code
			|| $game_r->player2->player_code eq $player_code )
	  );

	send_error( "Cannot make a move on a game that is not running.", 400 )
	  unless $game_r->game_status_value eq 'running';

	my $player = schema->resultset('Player')->find( { player_code => $player_code } );

	my $player_label;
	if ( $game_r->player1->player_code eq $player_code ) {
		$player_label = 'Player1';
	}
	elsif ( $game_r->player2->player_code eq $player_code ) {
		$player_label = 'Player2';
	}

	send_error( $player_label . " cannot move out of turn.", 400 )
	  if $player->id != $game_r->current_player->id;

	# Initialize game objects
	my $current_player = $game_r->current_player;
	my $winning_player = $game_r->winning_player;
	my $player1        = $game_r->player1;
	my $player2        = $game_r->player2;
	my $game           = Game::TicTacToe->new(
		is_public => $game_r->is_public,
		board     => Game::TicTacToe::Board->new( cell => _convert_board( $game_r->game_board ) ),
		(
			defined $current_player
			? (
				current => Game::TicTacToe::Player->new(
					name   => $current_player->player_name,
					type   => 'H',
					symbol => $current_player->player_mark,
					code   => $current_player->player_code,
				)
			  )
			: ()
		),
		players => [
			Game::TicTacToe::Player->new(
				name   => $player1->player_name,
				type   => 'H',
				symbol => $player1->player_mark,
				code   => $player1->player_code,
			),
			Game::TicTacToe::Player->new(
				name   => $player2->player_name,
				type   => 'H',
				symbol => $player2->player_mark,
				code   => $player2->player_code,
			),
		],
		(
			defined $winning_player
			? (
				winner => Game::TicTacToe::Player->new(
					name   => $winning_player->player_name,
					type   => 'H',
					symbol => $winning_player->player_mark,
					code   => $winning_player->player_code,
				)
			  )
			: ()
		),
		status    => $game_r->game_status_value,
		auth_code => $game_r->game_auth_code,
	);

	send_error( "Cannot move to space '$index' because it is already occupied.", 400 )
	  unless $game->is_valid_move($index);

	send_error( "Cannot make a move on a board for a game that is over.", 400 ) if $game->is_game_over;

	$game->play($index);

	#$game_r->save( $game->db_data() );

	status 201;
	header 'Location' => uri_for( '/game/' . $game_r->game_id );

	#return $game_r->rest_data();
	return $game->db_data();
};

1;

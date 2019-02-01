package TicTacToe::API;

use Dancer2;
use Dancer2::Plugin::DBIC;

use Game::TicTacToe;
use Game::TicTacToe::Board;
use Game::TicTacToe::Player;
use Game::TicTacToe::Move;

set serializer => 'JSON';

post '/game' => sub {

	# TODO: Params validation
	my $player1    = body_parameters->get('player1');
	my $goes_first = body_parameters->get('goes_first');

	my $game = Game::TicTacToe->new();
	$game->add_player1( $player1->{player_name}, $player1->{player_mark}, $goes_first );

	return {};
};

1;

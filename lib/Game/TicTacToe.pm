package Game::TicTacToe;

use Game::TicTacToe::Move;
use Game::TicTacToe::Board;
use Game::TicTacToe::Player;
use Game::TicTacToe::Types qw(Board PlayerType Players);

use Moo;
use namespace::clean;

has board => (
	is  => 'rw',
	isa => Board
);
has current => (
	is      => 'rw',
	isa     => PlayerType,
	default => sub { return 'H' },
);
has players => (
	is        => 'rw',
	isa       => Players,
	predicate => 1,
);
has size => (
	is      => 'ro',
	default => sub { return 3 }
);
has winner => (
	is        => 'rw',
	predicate => 1,
	clearer   => 1,
);

sub BUILD {
	my ($self) = @_;

	$self->set_game_board( $self->size );
	return;
}

sub set_game_board {
	my ( $self, $size ) = @_;

	my $cell = [ map { $_ } ( 1 .. ( $size * $size ) ) ];
	$self->board( Game::TicTacToe::Board->new( cell => $cell ) );
	return;
}

#XXX: Gonna rework this a bit to handle the "join" functionality I have in mind
sub set_players {
	my ( $self, $symbol ) = @_;

	if ( ( $self->has_players ) && ( scalar( @{ $self->players } ) == 2 ) ) {
		warn("WARNING: We already have 2 players to play the TicTacToe game.");
		return;
	}

	die "ERROR: Missing symbol for the player.\n" unless defined $symbol;

	# Player 1
	push @{ $self->{players} }, Games::TicTacToe::Player->new( type => 'H', symbol => uc($symbol) );

	# Player 2
	$symbol = ( uc($symbol) eq 'X' ) ? ('O') : ('X');
	push @{ $self->{players} }, Games::TicTacToe::Player->new( type => 'H', symbol => $symbol );

	return;
}

sub play {
	my ( $self, $move ) = @_;

	die("ERROR: Please add player before you start the game.\n")
	  unless ( ( $self->has_players ) && ( scalar( @{ $self->players } ) == 2 ) );

	my $player = $self->_get_current_player;
	my $board  = $self->board;

	#XXX: This has to change because I'm proabbly not gonna implement a computer player
	if ( defined $move && ( $self->_get_current_player->type eq 'H' ) ) {
		--$move;
	}
	else {
		$move = Games::TicTacToe::Move::now( $player, $board );
	}

	$board->setCell( $move, $player->symbol );
	$self->_resetCurrentPlayer unless ( $self->isGameOver );

	return;
}

sub is_last_move {
	my ($self) = @_;

	return ( $self->board->available_index !~ /\,/ );
}

sub is_game_over {
	my ($self) = @_;

	if ( !( $self->has_players ) || scalar( @{ $self->players } ) == 0 ) {
		warn("WARNING: No player found to play the TicTacToe game.");
		return;
	}

	my $board = $self->board;
	for my $player ( @{ $self->players } ) {
		if ( Games::TicTacToe::Move::foundWinner( $player, $board ) ) {
			$self->winner($player);
			return 1;
		}
	}

	return $board->isFull;
}

sub is_valid_move {
	my ( $self, $move ) = @_;

	return ( defined($move)
		  && ( $move =~ /^\d+$/ )
		  && ( $move >= 1 )
		  && ( $move <= $self->board->getSize )
		  && ( $self->board->isCellEmpty( $move - 1 ) ) );
}

sub is_valie_game_board_size {
	my ( $self, $size ) = @_;

	return ( defined $size && ( $size >= 3 ) );
}

### Private Methods ###

sub _get_current_player {
	my ($self) = @_;

	( $self->{players}->[0]->type eq $self->current )
	  ? ( return $self->{players}->[0] )
	  : ( return $self->{players}->[1] );

	return;
}

1;

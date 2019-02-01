package Game::TicTacToe;

use Game::TicTacToe::Move;
use Game::TicTacToe::Board;
use Game::TicTacToe::Player;
use Game::TicTacToe::Types qw(Board PlayerType Player Players GameStatus);

use Moo;
use namespace::clean;
use Types::Standard qw(Bool);
use Types::UUID;

has is_public => (
	is      => 'ro',
	isa     => Bool,
	default => sub { return 1 },
);

has board => (
	is  => 'rw',
	isa => Board,
);

has current => (
	is        => 'rw',
	isa       => Player,
	predicate => 1,

	#isa     => PlayerType,
	#default => sub { return 'H' },
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
	isa       => Player,
	predicate => 1,
	clearer   => 1,
);

has status => (
	is      => 'rw',
	isa     => GameStatus,
	default => sub { return 'waiting' },
);

has auth_code => (
	is      => 'ro',
	isa     => Uuid,
	lazy    => 1,
	builder => Uuid->generator,
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

sub add_player1 {
	my ( $self, $name, $symbol, $goes_first ) = @_;

	die("ERROR: Can only add player1 to a game in 'waiting' status") unless $self->status eq 'waiting';

	if ( ( $self->has_players ) && ( scalar( @{ $self->players } ) == 2 ) ) {
		warn("WARNING: We already have 2 players to play the TicTacToe game.");
		return;
	}

	die("ERROR: Player1 already exists for this game. Please join with Player2.")
	  unless ( $self->has_players && scalar( @{ $self->players } ) == 0 );

	# Add Player1
	push @{ $self->players }, Games::TicTacToe::Player->new( name => $name, symbol => uc($symbol) );

	# If there is no current player then we use $goes_first to set player1 if he chose to go first
	# otherwise player2 will get to go first when they join the game
	if ( not $self->has_current && defined $goes_first && $self->players->[0]->symbol eq $goes_first ) {
		$self->current( $self->players->[0] );
	}

	return;
}

sub join_player2 {
	my ( $self, $name ) = @_;

	die("ERROR: Can only join player2 to a game in 'waiting' status") unless $self->status eq 'waiting';

	if ( ( $self->has_players ) && ( scalar( @{ $self->players } ) == 2 ) ) {
		warn("WARNING: We already have 2 players to play the TicTacToe game.");
		return;
	}

	die("ERROR: Player2 already exists for this game.")
	  unless ( $self->has_players && scalar( @{ $self->players } ) == 1 );

	# Add Player2
	my $symbol = $self->players->[0]->other_symbol;
	push @{ $self->players }, Games::TicTacToe::Player->new( name => $name, symbol => uc($symbol) );

	if ( not $self->has_current ) {
		$self->current( $self->players->[1] );
	}

	$self->status('running');

	return;
}

sub play {
	my ( $self, $move ) = @_;

	die("ERROR: Please add players before you start the game.\n")
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

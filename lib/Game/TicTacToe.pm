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
	is        => 'rw',
	isa       => Board,
	predicate => 1,
);

has current => (
	is        => 'rw',
	isa       => Player,
	predicate => 1,
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

	if ( !$self->has_board ) {
		$self->set_game_board( $self->size );
	}
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
	  if ( $self->has_players && scalar( @{ $self->players } ) == 1 );

	# Add Player1
	push @{ $self->{players} }, Game::TicTacToe::Player->new( name => $name, symbol => uc($symbol) );

	# If there is no current player then we use $goes_first to set player1 if he chose to go first
	# otherwise player2 will get to go first when they join the game
	if ( !$self->has_current && defined $goes_first && $self->players->[0]->symbol eq $goes_first ) {
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
	push @{ $self->{players} }, Game::TicTacToe::Player->new( name => $name, symbol => uc($symbol) );

	if ( !$self->has_current ) {
		$self->current( $self->players->[1] );
	}

	$self->status('running');

	return;
}

sub play {
	my ( $self, $move ) = @_;

	die("ERROR: Game must be in the running status to play.")
	  unless $self->status eq 'running';

	my $player = $self->current;
	my $board  = $self->board;

	$board->set_cell( $move - 1, $player->symbol );
	$self->_reset_current_player unless ( $self->is_game_over );

	return;
}

sub is_game_over {
	my ($self) = @_;

	if ( !( $self->has_players ) || scalar( @{ $self->players } ) == 0 ) {
		warn("WARNING: No player found to play the TicTacToe game.");
		return;
	}

	my $board = $self->board;
	for my $player ( @{ $self->players } ) {
		if ( Game::TicTacToe::Move::found_winner( $player, $board ) ) {
			$self->winner($player);
			$self->status('complete');
			return 1;
		}
	}

	$self->status('complete') if $board->is_full;

	return $board->is_full;
}

sub is_valid_move {
	my ( $self, $move ) = @_;

	return ( defined($move)
		  && ( $move =~ /^\d+$/ )
		  && ( $move >= 1 )
		  && ( $move <= $self->board->get_size )
		  && ( $self->board->is_cell_empty( $move - 1 ) ) );
}

sub is_valid_game_board_size {
	my ( $self, $size ) = @_;

	return ( defined $size && ( $size >= 3 ) );
}

sub db_data {
	my ($self) = @_;

	my $player1 = $self->players->[0]->db_data();

	my $player2;
	if ( scalar( @{ $self->players } ) == 2 ) {
		$player2 = $self->players->[1]->db_data();
	}

	my ( $current_player, $winning_player );
	if ( $self->has_current ) {
		$current_player = $self->current->db_data();
	}
	if ( $self->has_winner ) {
		$winning_player = $self->winner->db_data();
	}

	#TODO: Need some logic for win_state_value, not gonna set it for now

	return {
		"is_public"         => $self->is_public,
		"player1"           => $player1,
		"player2"           => $player2,
		"current_player"    => $current_player,
		"winning_player"    => $winning_player,
		"game_status_value" => $self->status,
		"game_board"        => ( '[' . join( ",", @{ $self->board->cell } ) . ']' ),
		"game_auth_code"    => $self->auth_code,
	};
}

### Private Methods ###

sub _reset_current_player {
	my ($self) = @_;

	( $self->{players}->[0]->code eq $self->current->code )
	  ? ( $self->current( $self->{players}->[1] ) )
	  : ( $self->current( $self->{players}->[0] ) );

	return;
}

1;

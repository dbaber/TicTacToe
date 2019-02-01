package Game::TicTacToe::Player;

use Game::TicTacToe::Types qw(Symbol PlayerType);

use Moo;
use namespace::clean;
use Types::Standard qw(Str);
use Types::UUID;

has name => (
	is      => 'ro',
	isa     => Str,
	rquired => 1,
);

has type => (
	is       => 'ro',
	isa      => PlayerType,
	default  => sub { return 'H' },
	required => 1,
);

has symbol => (
	is       => 'ro',
	isa      => Symbol,
	default  => sub { return 'X' },
	required => 1,
);

has code => (
	is      => 'ro',
	isa     => Uuid,
	lazy    => 1,
	builder => Uuid->generator,
);

sub other_symbol {
	my ($self) = @_;

	return ( uc( $self->symbol ) eq 'X' ) ? 'O' : 'X';
}

#XXX: Probably won't use this
sub desc {
	my ($self) = @_;

	return ( $self->type eq 'H' ) ? ('Human') : ('Computer');
}

#XXX: Probably need something a bit different?
sub get_message {
	my ($self) = @_;

	if ( $self->type eq 'H' ) {
		return "<green><bold>Congratulation, you won the game.</bold></green>\n";
	}
	else {
		return "<red><bold>Computer beat you this time. Better luck next
	time.</bold></red>\n";
	}
}

1;

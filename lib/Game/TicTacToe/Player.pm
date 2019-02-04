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

sub db_data {
	my ($self) = @_;

	return {
		player_name => $self->name,
		player_code => $self->code,
		player_mark => $self->symbol,
	};
}

1;

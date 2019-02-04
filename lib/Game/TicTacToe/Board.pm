package Game::TicTacToe::Board;

use Moo;
use namespace::clean;

our $EMPTY = '\d';

has cell => (
	is      => 'rw',
	default => sub {
		return [qw/1 2 3 4 5 6 7 8 9/];
	},
);

sub get_size {
	my ($self) = @_;

	return scalar( @{ $self->cell } );
}

sub is_full {
	my ($self) = @_;

	my $size = $self->get_size();
	for my $i ( 0 .. ( $size - 1 ) ) {
		return 0 if $self->is_cell_empty($i);
	}

	return 1;
}

sub set_cell {
	my ( $self, $index, $symbol ) = @_;

	die("ERROR: Missing cell index for TicTacToe Board.\n") unless defined $index;
	die("ERROR: Missing symbol for TicTacToe Board.\n")     unless defined $symbol;
	die("ERROR: Invalid symbol for TicTacToe Board.\n")     unless ( $symbol =~ /^[X|O]$/i );

	my $size = $self->get_size();
	if ( ( $index =~ /^\d*$/ ) && ( $index >= 0 ) && ( $index < $size ) ) {
		$self->cell->[$index] = $symbol;
	}
	else {
		die("ERROR: Invalid cell index value for TicTacToe Board.\n");
	}

	return;
}

sub get_cell {
	my ( $self, $index ) = @_;

	die("ERROR: Missing cell index for TicTacToe Board.\n") unless defined($index);

	my $size = $self->get_size();
	if ( ( $index =~ /^\d*$/ ) && ( $index >= 0 ) && ( $index < $size ) ) {
		return $self->cell->[$index];
	}
	else {
		die("ERROR: Invalid index value for TicTacToe Board.\n");
	}
}

sub is_cell_empty {
	my ( $self, $index ) = @_;

	return ( $self->get_cell($index) =~ /$EMPTY/ );
}

sub cell_contains {
	my ( $self, $index, $symbol ) = @_;

	return ( $self->get_cell($index) eq $symbol );
}

sub belongs_to_player {
	my ( $self, $cells, $player ) = @_;

	my $symbol = $player->symbol;
	my $size   = sqrt( $self->get_size() );
	for my $i ( 0 .. ( $size - 1 ) ) {
		return 0 unless ( $self->cell_contains( $cells->[$i], $symbol ) );
	}

	return 1;
}

1;

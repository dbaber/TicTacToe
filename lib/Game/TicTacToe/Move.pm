package Game::TicTacToe::Move;

use strict;
use warnings;

sub found_winner {
	my ( $player, $board ) = @_;

	die("ERROR: Player not defined.\n") unless defined $player;
	die("ERROR: Board not defined.\n")  unless defined $board;

	my $size          = sqrt( $board->getSize );
	my $winning_moves = ___winning_moves($size);
	for my $move (@$winning_moves) {
		return 1 if $board->belongsToPlayer( $move, $player );
	}

	return 0;
}

sub __winning_moves {
	my ($size) = @_;

	my $moves = [];

	# Horizontal
	my $_moves = [];
	my $k      = 0;
	for my $i ( 1 .. $size ) {
		$_moves = [];
		for my $j ( 1 .. $size ) {
			push @$_moves, $k++;
		}
		push @$moves, $_moves;
	}

	# Vertical
	for my $i ( 1 .. $size ) {
		$_moves = [];
		$k      = 0;
		for my $j ( 1 .. $size ) {
			push @$_moves, ( $i + ( $size * $k ) ) - 1;
			$k++;
		}
		push @$moves, $_moves;
	}

	# Diagonal (left to right)
	$_moves = [];
	my $j = 1;
	for my $i ( 0 .. $size - 1 ) {
		push @$_moves, ( $j + ( $i * $size ) ) - 1;
		$j++;
	}
	push @$moves, $_moves;

	# Diagonal (right to left)
	$_moves = [];
	$j      = 0;
	for my $i ( 1 .. $size ) {
		push @$_moves, ( ( $i * $size ) - $j ) - 1;
		$j++;
	}
	push @$moves, $_moves;

	return $moves;
}

1;

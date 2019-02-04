use strict;
use warnings;

use Test::More tests => 221;
use Plack::Test;
use HTTP::Request::Common;
use JSON;

use TicTacToe::Test qw(prepare_db get_psgi_app);

use TicTacToe::Test::Utils qw(
  create_running_game
  make_game_moves
  check_game
);

prepare_db();

my $app  = get_psgi_app();
my $test = Plack::Test->create($app);

# Top horizontal row win for 'X'
#
# Board
# =====
# X X X
# O O 6
# 7 8 9
#
# String: '[X,X,X,O,O,6,7,8,9]'
#
# Moves: 1X,4O,2X,5O,3X
top_horizontal_row_win_for_x: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/1X 4O 2X 5O 3X/],
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 5 ], "Created game where player1 or 'X' wins top horizontal row" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player1',
		game_status    => 'complete',
		game_board     => '[X,X,X,O,O,6,7,8,9]',
		winning_player => 'player1',
	);
}

# Top horizontal row win for 'O'
#
# Board
# =====
# O O O
# X X O
# X X 9
#
# String: '[O,O,O,X,X,O,X,X,9]'
#
# Moves: 4X,1O,5X,6O,7X,3O,8X,2O
top_horizontal_row_win_for_o: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/4X 1O 5X 6O 7X 3O 8X 2O/]
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 8 ], "Created game where player2 or 'O' wins with top horizontal row" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player2',
		game_status    => 'complete',
		game_board     => '[O,O,O,X,X,O,X,X,9]',
		winning_player => 'player2',
	);
}

# Middle horizontal row win for 'X'
#
# Board
# =====
# O O 3
# X X X
# 7 8 9
#
# String: '[O,O,3,X,X,X,7,8,9]'
#
# Moves: 4X,1O,5X,2O,6X
middle_horizontal_row_win_for_x: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/4X 1O 5X 2O 6X/]
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 5 ], "Created game where player1 or 'X' wins with middle horizontal row" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player1',
		game_status    => 'complete',
		game_board     => '[O,O,3,X,X,X,7,8,9]',
		winning_player => 'player1',
	);
}

# Middle horizontal row win for 'O'
#
# Board
# =====
# X X O
# O O O
# X X 9
#
# String: '[X,X,O,O,O,O,X,X,9]'
#
# Moves: 1X,4O,2X,3O,8X,5O,7X,6O
middle_horizontal_row_win_for_o: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/1X 4O 2X 3O 8X 5O 7X 6O/],
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 8 ], "Created game where player2 or 'O' wins with middle horizontal row" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player2',
		game_status    => 'complete',
		game_board     => '[X,X,O,O,O,O,X,X,9]',
		winning_player => 'player2',
	);
}

# Bottom horizontal row win for 'X'
#
# Board
# =====
# 1 2 3
# O O 6
# X X X
#
# String: '[1,2,3,O,O,6,X,X,X]'
#
# Moves: 7X,4O,8X,5O,9X
bottom_horizontal_row_win_for_x: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/7X 4O 8X 5O 9X/],
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 5 ], "Created game where player1 or 'X' wins with bottom horizontal row" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player1',
		game_status    => 'complete',
		game_board     => '[1,2,3,O,O,6,X,X,X]',
		winning_player => 'player1',
	);
}

# Bottom horizontal row win for 'O'
#
# Board
# =====
# X X O
# X X 6
# O O O
#
# String: '[X,X,O,X,X,6,O,O,O]'
#
# Moves: 1X,7O,2X,3O,5X,8O,4X,9O
bottom_horizontal_row_win_for_o: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/1X 7O 2X 3O 5X 8O 4X 9O/],
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 8 ], "Created game where player2 or 'O' wins with bottom horizontal row" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player2',
		game_status    => 'complete',
		game_board     => '[X,X,O,X,X,6,O,O,O]',
		winning_player => 'player2',
	);
}

# Left vertical col win for 'X'
#
# Board
# =====
# X O 3
# X O 6
# X 8 9
#
# String: '[X,O,3,X,O,6,X,8,9]'
#
# Moves: 1X,2O,4X,5O,7X
left_vertical_col_win_for_x: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/1X 2O 4X 5O 7X/],
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 5 ], "Created game where player1 or 'X' wins with left vertical col" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player1',
		game_status    => 'complete',
		game_board     => '[X,O,3,X,O,6,X,8,9]',
		winning_player => 'player1',
	);
}

# Left vertical col win for 'O'
#
# Board
# =====
# O X X
# O X X
# O O 9
#
# String: '[O,X,X,O,X,X,O,O,9]'
#
# Moves: 5X,1O,2X,8O,6X,4O,3X,7O
left_vertical_col_win_for_o: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/5X 1O 2X 8O 6X 4O 3X 7O/],
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 8 ], "Created game where player2 or 'O' wins with left vertical col" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player2',
		game_status    => 'complete',
		game_board     => '[O,X,X,O,X,X,O,O,9]',
		winning_player => 'player2',
	);
}

# Middle vertical col win for 'X'
#
# Board
# =====
# O X 3
# O X 6
# 7 X 9
#
# String: '[O,X,3,O,X,6,7,X,9]'
#
# Moves: 5X,1O,8X,4O,2X
middle_vertical_col_win_for_x: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/5X 1O 8X 4O 2X/],
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 5 ], "Created game where player1 or 'X' wins with middle vertical col" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player1',
		game_status    => 'complete',
		game_board     => '[O,X,3,O,X,6,7,X,9]',
		winning_player => 'player1',
	);
}

# Middle vertical col win for 'O'
#
# Board
# =====
# X O X
# X O X
# O O 9
#
# String: '[X,O,X,X,O,X,O,O,9]'
#
# Moves: 1X,5O,4X,7O,3X,2O,6X,8O
middle_vertical_col_win_for_o: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/1X 5O 4X 7O 3X 2O 6X 8O/],
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 8 ], "Created game where player2 or 'O' wins with middle vertical col" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player2',
		game_status    => 'complete',
		game_board     => '[X,O,X,X,O,X,O,O,9]',
		winning_player => 'player2',
	);
}

# Right vertical col win for 'X'
#
# Board
# =====
# 1 O X
# 4 O X
# 7 8 X
#
# String: '[1,O,X,4,O,X,7,8,X]'
#
# Moves: 3X,2O,6X,5O,9X
right_vertical_col_win_for_x: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/3X 2O 6X 5O 9X/],
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 5 ], "Created game where player1 or 'X' wins with right vertical col" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player1',
		game_status    => 'complete',
		game_board     => '[1,O,X,4,O,X,7,8,X]',
		winning_player => 'player1',
	);
}

# Right vertical col win for 'O'
#
# Board
# =====
# X 2 O
# X X O
# O X O
#
# String: '[X,2,O,X,X,O,O,X,O]'
#
# Moves: 1X,3O,4X,7O,5X,6O,8X,9O
right_vertical_col_win_for_o: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/1X 3O 4X 7O 5X 6O 8X 9O/],
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 8 ], "Created game where player2 or 'O' wins with right vertical col" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player2',
		game_status    => 'complete',
		game_board     => '[X,2,O,X,X,O,O,X,O]',
		winning_player => 'player2',
	);
}

# Left to right diagonal win for 'X'
#
# Board
# =====
# X O O
# 4 X 6
# 7 8 X
#
# String: '[X,O,O,4,X,6,7,8,X]'
#
# Moves: 1X,2O,5X,3O,9X
left_to_right_diagonal_win_for_x: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/1X 2O 5X 3O 9X/],
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 5 ], "Created game where player1 or 'X' wins with left to right diagonal" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player1',
		game_status    => 'complete',
		game_board     => '[X,O,O,4,X,6,7,8,X]',
		winning_player => 'player1',
	);
}

# Left to right diagonal win for 'O'
#
# Board
# =====
# O X X
# 4 O X
# 7 8 O
#
# String: '[O,X,X,4,O,X,7,8,O]'
#
# Moves: 6X,5O,3X,9O,2X,1O
left_to_right_diagonal_win_for_o: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/6X 5O 3X 9O 2X 1O/],
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 6 ], "Created game where player2 or 'O' wins left to right diagonal" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player2',
		game_status    => 'complete',
		game_board     => '[O,X,X,4,O,X,7,8,O]',
		winning_player => 'player2',
	);
}

# Right to left diagonal win for 'X'
#
# Board
# =====
# O O X
# 4 X 6
# X 8 9
#
# String: '[O,O,X,4,X,6,X,8,9]'
#
# Moves: 5X,1O,7X,2O,3X
right_to_left_diagonal_win_for_x: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/5X 1O 7X 2O 3X/],
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 5 ], "Created game where player1 or 'X' wins with right to left diagonal" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player1',
		game_status    => 'complete',
		game_board     => '[O,O,X,4,X,6,X,8,9]',
		winning_player => 'player1',
	);
}

# Right to left diagonal win for 'O'
#
# Board
# =====
# X X O
# X O 6
# O 8 9
#
# String: '[X,X,O,X,O,6,O,8,9]'
#
# Moves: 1X,5O,4X,7O,2X,3O
right_to_left_diagonal_win_for_o: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/1X 5O 4X 7O 2X 3O/],
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 6 ], "Created game where player2 or 'O' wins right to left diagonal" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player2',
		game_status    => 'complete',
		game_board     => '[X,X,O,X,O,6,O,8,9]',
		winning_player => 'player2',
	);
}

# Cats game
#
# Board
# =====
# X O X
# O X X
# O X O
#
# String: '[X,O,X,O,X,X,O,X,O]'
#
# Moves: 5X,7O,1X,9O,8X,2O,6X,4O,3X
cats_game: {
	my $game = create_running_game(
		test         => $test,
		player1_name => 'Dan',
		player1_mark => 'X',
		goes_first   => 'X',
		player2_name => 'Ben'
	);

	my $responses = make_game_moves(
		test  => $test,
		game  => $game,
		moves => [qw/5X 7O 1X 9O 8X 2O 6X 4O 3X/],
	);
	my @response_codes = map { $_->code } @$responses;
	is_deeply( \@response_codes, [ (201) x 9 ], "Created game that ends in a cats game" );

	my $response = $responses->[-1];
	my $decoded  = from_json( $response->content );
	check_game(
		response       => $response,
		game           => $decoded,
		player1_name   => 'Dan',
		player1_mark   => 'X',
		player2_name   => 'Ben',
		player2_mark   => 'O',
		current_player => 'player1',
		game_status    => 'complete',
		game_board     => '[X,O,X,O,X,X,O,X,O]',
		winning_player => undef,
	);
}

1;

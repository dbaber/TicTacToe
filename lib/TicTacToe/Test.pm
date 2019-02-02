package TicTacToe::Test;

use strict;
use warnings;
use Dancer2 appname => 'TicTacToe::API';
use Dancer2::Plugin::DBIC;
use Dir::Self;
use File::Slurp qw(slurp);

use TicTacToe::API;

BEGIN {
	$ENV{DANCER_ENVIRONMENT} = "testing";
}

sub prepare_db {
	my $dbh = schema->storage->dbh;

	#XXX: I believe these DROP TABLE statements work because I set no real FK drop constraints?
	$dbh->do("DROP TABLE IF EXISTS game");
	$dbh->do("DROP TABLE IF EXISTS player");
	$dbh->do("DROP TABLE IF EXISTS lookup_game_status");
	$dbh->do("DROP TABLE IF EXISTS lookup_win_state");

	my $test_db = __DIR__ . '../../db/tictactoe_testing.db';

	#	#XXX: I don't think I need this, shouldn't schema above create the DB?
	#	if ( !-e $test_db ) {
	#		die("Please use sqlite3 to create the testing database: sqlite3 db/tictactoe_testing.db < db/tictactoe.sql!");
	#	}
	#
	my $sql = slurp($test_db);
	$dbh->do($sql);

	return;
}

sub get_psgi_app {
	return TicTacToe::API->to_app();
}

1;

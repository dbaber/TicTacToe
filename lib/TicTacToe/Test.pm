package TicTacToe::Test;

use strict;
use warnings;

BEGIN {
	$ENV{DANCER_ENVIRONMENT} = "testing";
}

use Dancer2 appname => 'TicTacToe::API';
use Dancer2::Plugin::DBIC;
use Dir::Self;
use File::Slurp qw(slurp);
use Plack::Builder;

use TicTacToe;
use TicTacToe::API;

use Sub::Exporter -setup => {
	exports => [
		qw/
		  prepare_db
		  get_psgi_app
		  get_config
		  /
	],
};

sub prepare_db {
	my $dbh = schema->storage->dbh;

	#XXX: I believe these DROP TABLE statements work because I set no real FK drop constraints?
	$dbh->do("DROP TABLE IF EXISTS game");
	$dbh->do("DROP TABLE IF EXISTS player");
	$dbh->do("DROP TABLE IF EXISTS lookup_game_status");
	$dbh->do("DROP TABLE IF EXISTS lookup_win_state");

	my $sql_file = __DIR__ . '/../../db/tictactoe.sql';
	my $sql      = slurp($sql_file);

	#XXX: This only works if you set the option 'sqlite_allow_multiple_statements' in your test DB config
	$dbh->do($sql);

	return;
}

sub get_psgi_app {
	my $app = builder {
		mount '/'    => TicTacToe->to_app;
		mount '/api' => TicTacToe::API->to_app;
	};

	return $app;
}

sub get_config {
	return config;
}

1;

package Game::TicTacToe::Types;

use strict;
use warnings;

use Type::Library -base,
  -declare => qw(Board Player Players PlayerType Symbol Type);
use Types::Standard qw(Str ArrayRef);
use Type::Utils;

class_type 'Board',  { class => 'Game::TicTacToe::Board' };
class_type 'Player', { class => 'Game::TicTacToe::Player' };

declare 'PlayerType', as Str,
  where { ( defined $_[0] && $_[0] =~ /^[H|C]$/i ) },
  message { "isa check for 'PlayerType' failed." };

declare 'Players', as ArrayRef [Player],
  message { "isa check for 'players' failed." };

declare 'Symbol', as Str,
  where { ( defined $_[0] && $_[0] =~ /^[X|O]$/i ) },
  message { "isa check for 'symbol' failed." };

declare 'Type', as Str,
  where { ( defined $_[0] && $_[0] =~ /^[H|C]$/i ) },
  message { "isa check for 'type' failed." };

1;

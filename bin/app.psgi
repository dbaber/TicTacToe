#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use TicTacToe;
use TicTacToe::API;
use Plack::Builder;

builder {
    mount '/'    => TicTacToe->to_app;
    mount '/api' => TicTacToe::API->to_app;
}

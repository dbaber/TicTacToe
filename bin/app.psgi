#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use TicTacToe;
use TicTacToe::API;
use Plack::Builder;

builder {
# TODO: Could use the templates and other routes to build a UI on '/', so I'll split it off from the API
    mount '/'    => TicTacToe->to_app;
    mount '/api' => TicTacToe::API->to_app;
}

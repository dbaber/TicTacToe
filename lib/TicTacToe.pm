package TicTacToe;
use Dancer2;

our $VERSION = '0.1';

get '/' => sub {
    template 'index' => { 'title' => 'TicTacToe' };
};

true;

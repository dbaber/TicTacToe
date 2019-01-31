package TicTacToe::API;
use Dancer2;
set serializer => 'JSON';

get '/game' => sub {
    return { foo => "bar" };
};

1;

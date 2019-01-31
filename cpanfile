requires 'Dancer2', '0.207000';
requires 'Dancer2::Plugin::DBIC', '0.0100';
requires 'Moo', '2.003004';
requires 'namespace::clean', '0.27';

recommends 'YAML'             => '0';
recommends 'URL::Encode::XS'  => '0';
recommends 'CGI::Deurl::XS'   => '0';
recommends 'HTTP::Parser::XS' => '0';

on 'test' => sub {
    requires 'Test::More'            => '0';
    requires 'HTTP::Request::Common' => '0';
};

requires 'Dancer2'               => '0.207000';
requires 'Dancer2::Plugin::DBIC' => '0.0100';
requires 'Moo'                   => '2.003004';
requires 'namespace::clean'      => '0.27';
requires 'Type::Tiny'            => '1.004004';
requires 'Types::UUID'           => '0.004';
requires 'Dir::Self'             => '0.11';
requires 'File::Slurp'           => '9999.25';
requires 'Sub::Exporter'         => '0.987';

recommends 'YAML'             => '0';
recommends 'URL::Encode::XS'  => '0';
recommends 'CGI::Deurl::XS'   => '0';
recommends 'HTTP::Parser::XS' => '0';

on 'test' => sub {
	requires 'Test::More'            => '0';
	requires 'HTTP::Request::Common' => '0';
};

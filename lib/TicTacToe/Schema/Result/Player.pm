use utf8;

package TicTacToe::Schema::Result::Player;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TicTacToe::Schema::Result::Player

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<player>

=cut

__PACKAGE__->table("player");

=head1 ACCESSORS

=head2 player_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 player_name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 player_code

  data_type: 'char'
  is_nullable: 0
  size: 36

=head2 player_mark

  data_type: 'char'
  is_nullable: 0
  size: 1

=cut

__PACKAGE__->add_columns(
	"player_id",   { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"player_name", { data_type => "varchar", is_nullable       => 0, size        => 255 },
	"player_code", { data_type => "char",    is_nullable       => 0, size        => 36 },
	"player_mark", { data_type => "char",    is_nullable       => 0, size        => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</player_id>

=back

=cut

__PACKAGE__->set_primary_key("player_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<player_code_unique>

=over 4

=item * L</player_code>

=back

=cut

__PACKAGE__->add_unique_constraint( "player_code_unique", ["player_code"] );

=head1 RELATIONS

=head2 game_current_players

Type: has_many

Related object: L<TicTacToe::Schema::Result::Game>

=cut

__PACKAGE__->has_many(
	"game_current_players",
	"TicTacToe::Schema::Result::Game",
	{ "foreign.current_player_id" => "self.player_id" },
	{ cascade_copy                => 0, cascade_delete => 0 },
);

=head2 game_player1s

Type: has_many

Related object: L<TicTacToe::Schema::Result::Game>

=cut

__PACKAGE__->has_many(
	"game_player1s",
	"TicTacToe::Schema::Result::Game",
	{ "foreign.player1_id" => "self.player_id" },
	{ cascade_copy         => 0, cascade_delete => 0 },
);

=head2 game_player2s

Type: has_many

Related object: L<TicTacToe::Schema::Result::Game>

=cut

__PACKAGE__->has_many(
	"game_player2s",
	"TicTacToe::Schema::Result::Game",
	{ "foreign.player2_id" => "self.player_id" },
	{ cascade_copy         => 0, cascade_delete => 0 },
);

=head2 game_winning_players

Type: has_many

Related object: L<TicTacToe::Schema::Result::Game>

=cut

__PACKAGE__->has_many(
	"game_winning_players",
	"TicTacToe::Schema::Result::Game",
	{ "foreign.winning_player_id" => "self.player_id" },
	{ cascade_copy                => 0, cascade_delete => 0 },
);

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-01-30 03:11:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uvec5gIM5x/X+mMLcPiOmQ

# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub save {
	my ( $self, $data, $opts ) = @_;

	#TODO: Add some sort of validation here too :\
	#$data = $self->_validate( $data, $opts );

	$opts->{discard_changes} //= 1;

	#TODO: This bit should probably be wrapped in a try/catch via Try::Tiny
	$self->set_columns($data);
	$self->update_or_insert;

	$self->discard_changes if $opts->{discard_changes};

	return $self;
}

sub rest_data {
	my ( $self, %args ) = @_;

	my $data = {};
	$data->{$_} = $self->$_ for qw{
	  player_id
	  player_name
	  player_code
	  player_mark
	};

	return $data;
}

1;

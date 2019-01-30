use utf8;
package TicTacToe::Schema::Result::Game;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TicTacToe::Schema::Result::Game

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

=head1 TABLE: C<game>

=cut

__PACKAGE__->table("game");

=head1 ACCESSORS

=head2 game_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 is_public

  data_type: 'boolean'
  default_value: 1
  is_nullable: 0

=head2 player1_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 player2_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 current_player_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 winning_player_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 game_status_value

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 255

=head2 game_board

  data_type: 'varchar'
  default_value: '["_","_","_","_","_","_","_","_","_"]'
  is_nullable: 0
  size: 255

=head2 game_auth_code

  data_type: 'char'
  is_nullable: 0
  size: 36

=head2 win_state_value

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "game_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "is_public",
  { data_type => "boolean", default_value => 1, is_nullable => 0 },
  "player1_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "player2_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "current_player_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "winning_player_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "game_status_value",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 255 },
  "game_board",
  {
    data_type => "varchar",
    default_value => "[\"_\",\"_\",\"_\",\"_\",\"_\",\"_\",\"_\",\"_\",\"_\"]",
    is_nullable => 0,
    size => 255,
  },
  "game_auth_code",
  { data_type => "char", is_nullable => 0, size => 36 },
  "win_state_value",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</game_id>

=back

=cut

__PACKAGE__->set_primary_key("game_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<game_auth_code_unique>

=over 4

=item * L</game_auth_code>

=back

=cut

__PACKAGE__->add_unique_constraint("game_auth_code_unique", ["game_auth_code"]);

=head1 RELATIONS

=head2 current_player

Type: belongs_to

Related object: L<TicTacToe::Schema::Result::Player>

=cut

__PACKAGE__->belongs_to(
  "current_player",
  "TicTacToe::Schema::Result::Player",
  { player_id => "current_player_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 game_status_value

Type: belongs_to

Related object: L<TicTacToe::Schema::Result::LookupGameStatus>

=cut

__PACKAGE__->belongs_to(
  "game_status_value",
  "TicTacToe::Schema::Result::LookupGameStatus",
  { game_status_value => "game_status_value" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 player1

Type: belongs_to

Related object: L<TicTacToe::Schema::Result::Player>

=cut

__PACKAGE__->belongs_to(
  "player1",
  "TicTacToe::Schema::Result::Player",
  { player_id => "player1_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 player2

Type: belongs_to

Related object: L<TicTacToe::Schema::Result::Player>

=cut

__PACKAGE__->belongs_to(
  "player2",
  "TicTacToe::Schema::Result::Player",
  { player_id => "player2_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 win_state_value

Type: belongs_to

Related object: L<TicTacToe::Schema::Result::LookupWinState>

=cut

__PACKAGE__->belongs_to(
  "win_state_value",
  "TicTacToe::Schema::Result::LookupWinState",
  { win_state_value => "win_state_value" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 winning_player

Type: belongs_to

Related object: L<TicTacToe::Schema::Result::Player>

=cut

__PACKAGE__->belongs_to(
  "winning_player",
  "TicTacToe::Schema::Result::Player",
  { player_id => "winning_player_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-01-30 03:15:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:b5b1ekzRMOagfLIl1cs6WA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

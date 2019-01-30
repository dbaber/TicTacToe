use utf8;
package TicTacToe::Schema::Result::LookupWinState;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TicTacToe::Schema::Result::LookupWinState

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

=head1 TABLE: C<lookup_win_state>

=cut

__PACKAGE__->table("lookup_win_state");

=head1 ACCESSORS

=head2 win_state_value

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "win_state_value",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</win_state_value>

=back

=cut

__PACKAGE__->set_primary_key("win_state_value");

=head1 RELATIONS

=head2 games

Type: has_many

Related object: L<TicTacToe::Schema::Result::Game>

=cut

__PACKAGE__->has_many(
  "games",
  "TicTacToe::Schema::Result::Game",
  { "foreign.win_state_value" => "self.win_state_value" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-01-30 03:11:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ffo8RpMvNpCEi+aAqMPX4Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

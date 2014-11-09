use utf8;
package TearDrop::Model::Result::Workqueue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::Workqueue

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::Helper::Row::ToJSON>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "Helper::Row::ToJSON");

=head1 TABLE: C<workqueue>

=cut

__PACKAGE__->table("workqueue");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'workqueue_id_seq'

=head2 pid

  data_type: 'integer'
  is_nullable: 1

=head2 submit_date

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=head2 start_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 stop_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 status

  data_type: 'text'
  default_value: 'queued'
  is_nullable: 0

=head2 errmsg

  data_type: 'text'
  is_nullable: 1

=head2 class

  data_type: 'text'
  is_nullable: 0

=head2 task_object

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "workqueue_id_seq",
  },
  "pid",
  { data_type => "integer", is_nullable => 1 },
  "submit_date",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 1,
    original      => { default_value => \"now()" },
  },
  "start_date",
  { data_type => "timestamp", is_nullable => 1 },
  "stop_date",
  { data_type => "timestamp", is_nullable => 1 },
  "status",
  { data_type => "text", default_value => "queued", is_nullable => 0 },
  "errmsg",
  { data_type => "text", is_nullable => 1 },
  "class",
  { data_type => "text", is_nullable => 0 },
  "task_object",
  { data_type => "text", is_nullable => 0, 'serializer_class' => 'Storable' },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-09 23:50:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JBMvZpaa4hrzJa5HwrpXrw

__PACKAGE__->load_components('InflateColumn::Serializer', 'Core');



# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

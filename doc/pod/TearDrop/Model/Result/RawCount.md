# NAME

TearDrop::Model::Result::RawCount

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `raw_counts`

# ACCESSORS

## id

    data_type: 'integer'
    is_auto_increment: 1
    is_nullable: 0
    sequence: 'raw_counts_id_seq'

## transcript\_id

    data_type: 'text'
    is_foreign_key: 1
    is_nullable: 0

## sample\_count\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## count

    data_type: 'double precision'
    is_nullable: 1

## tpm

    data_type: 'double precision'
    is_nullable: 1

# PRIMARY KEY

- ["id"](#id)

# UNIQUE CONSTRAINTS

## `raw_counts_transcript_id_sample_count_id_key`

- ["transcript\_id"](#transcript_id)
- ["sample\_count\_id"](#sample_count_id)

# RELATIONS

## sample\_count

Type: belongs\_to

Related object: [TearDrop::Model::Result::SampleCount](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/SampleCount.md)

## table\_counts

Type: has\_many

Related object: [TearDrop::Model::Result::TableCount](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/TableCount.md)

## transcript

Type: belongs\_to

Related object: [TearDrop::Model::Result::Transcript](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Transcript.md)

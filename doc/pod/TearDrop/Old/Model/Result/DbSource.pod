# NAME

TearDrop::Old::Model::Result::DbSource

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `db_sources`

# ACCESSORS

## id

    data_type: 'integer'
    is_auto_increment: 1
    is_nullable: 0
    sequence: 'db_sources_id_seq'

## description

    data_type: 'text'
    is_nullable: 0

## dbtype

    data_type: 'text'
    is_nullable: 1

## url

    data_type: 'text'
    is_nullable: 1

## version

    data_type: 'text'
    is_nullable: 1

## downloaded

    data_type: 'timestamp'
    is_nullable: 1

## path

    data_type: 'text'
    is_nullable: 1

## name

    data_type: 'text'
    is_nullable: 0

# PRIMARY KEY

- ["id"](#id)

# UNIQUE CONSTRAINTS

## `db_sources_description_key`

- ["description"](#description)

## `db_sources_name_unique`

- ["name"](#name)

# RELATIONS

## blast\_results

Type: has\_many

Related object: [TearDrop::Old::Model::Result::BlastResult](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/BlastResult.md)

## blast\_runs

Type: has\_many

Related object: [TearDrop::Old::Model::Result::BlastRun](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/BlastRun.md)

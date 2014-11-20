# NAME

TearDrop::Master::Model::Result::DbSource

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)
- [DBIx::Class::InflateColumn::Serializer](https://metacpan.org/pod/DBIx::Class::InflateColumn::Serializer)

# TABLE: `db_sources`

# ACCESSORS

## id

    data_type: 'integer'
    is_auto_increment: 1
    is_nullable: 0
    sequence: 'db_sources_id_seq'

## name

    data_type: 'text'
    is_nullable: 0

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

# PRIMARY KEY

- ["id"](#id)

# UNIQUE CONSTRAINTS

## `db_sources_description_key`

- ["description"](#description)

## `db_sources_name_key`

- ["name"](#name)

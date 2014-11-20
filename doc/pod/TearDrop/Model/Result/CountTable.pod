# NAME

TearDrop::Model::Result::CountTable

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `count_tables`

# ACCESSORS

## id

    data_type: 'integer'
    is_auto_increment: 1
    is_nullable: 0
    sequence: 'count_tables_id_seq'

## name

    data_type: 'text'
    is_nullable: 0

## description

    data_type: 'text'
    is_nullable: 1

## aggregate\_genes

    data_type: 'boolean'
    default_value: false
    is_nullable: 1

## subset\_of

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 1

# PRIMARY KEY

- ["id"](#id)

# UNIQUE CONSTRAINTS

## `count_tables_name_key`

- ["name"](#name)

# RELATIONS

## count\_tables

Type: has\_many

Related object: [TearDrop::Model::Result::CountTable](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/CountTable.md)

## de\_runs

Type: has\_many

Related object: [TearDrop::Model::Result::DeRun](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/DeRun.md)

## subset\_of

Type: belongs\_to

Related object: [TearDrop::Model::Result::CountTable](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/CountTable.md)

## table\_counts

Type: has\_many

Related object: [TearDrop::Model::Result::TableCount](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/TableCount.md)

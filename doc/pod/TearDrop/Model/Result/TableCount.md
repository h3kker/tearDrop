# NAME

TearDrop::Model::Result::TableCount

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `table_counts`

# ACCESSORS

## count\_table\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## raw\_count\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

# UNIQUE CONSTRAINTS

## `table_counts_count_table_id_raw_count_id_key`

- ["count\_table\_id"](#count_table_id)
- ["raw\_count\_id"](#raw_count_id)

# RELATIONS

## count\_table

Type: belongs\_to

Related object: [TearDrop::Model::Result::CountTable](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/CountTable.md)

## raw\_count

Type: belongs\_to

Related object: [TearDrop::Model::Result::RawCount](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/RawCount.md)

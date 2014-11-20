# NAME

TearDrop::Old::Model::Result::DeRun

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `de_runs`

# ACCESSORS

## id

    data_type: 'integer'
    is_auto_increment: 1
    is_nullable: 0
    sequence: 'de_runs_id_seq'

## description

    data_type: 'text'
    is_nullable: 1

## run\_date

    data_type: 'timestamp'
    is_nullable: 1

## parameters

    data_type: 'text'
    is_nullable: 1

## path

    data_type: 'text'
    is_nullable: 1

## count\_table\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## name

    data_type: 'text'
    is_nullable: 0

## sha1

    data_type: 'text'
    is_nullable: 1

## imported

    data_type: 'boolean'
    default_value: false
    is_nullable: 1

# PRIMARY KEY

- ["id"](#id)

# UNIQUE CONSTRAINTS

## `de_runs_name_key`

- ["name"](#name)

# RELATIONS

## count\_table

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::CountTable](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/CountTable.md)

## de\_results

Type: has\_many

Related object: [TearDrop::Old::Model::Result::DeResult](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/DeResult.md)

## de\_run\_contrasts

Type: has\_many

Related object: [TearDrop::Old::Model::Result::DeRunContrast](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/DeRunContrast.md)

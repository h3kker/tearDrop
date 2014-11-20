# NAME

TearDrop::Model::Result::SampleCount

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `sample_counts`

# ACCESSORS

## id

    data_type: 'integer'
    is_auto_increment: 1
    is_nullable: 0
    sequence: 'sample_counts_id_seq'

## sample\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## count\_method

    data_type: 'text'
    is_foreign_key: 1
    is_nullable: 0

## call

    data_type: 'text'
    is_nullable: 1

## path

    data_type: 'text'
    is_nullable: 0

## mapped\_ratio

    data_type: 'double precision'
    is_nullable: 1

## run\_date

    data_type: 'timestamp'
    is_nullable: 1

# PRIMARY KEY

- ["id"](#id)

# RELATIONS

## count\_method

Type: belongs\_to

Related object: [TearDrop::Model::Result::CountMethod](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/CountMethod.md)

## raw\_counts

Type: has\_many

Related object: [TearDrop::Model::Result::RawCount](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/RawCount.md)

## sample

Type: belongs\_to

Related object: [TearDrop::Model::Result::Sample](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Sample.md)

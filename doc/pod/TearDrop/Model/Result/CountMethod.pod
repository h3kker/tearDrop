# NAME

TearDrop::Model::Result::CountMethod

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `count_methods`

# ACCESSORS

## name

    data_type: 'text'
    is_nullable: 0

## program

    data_type: 'text'
    is_nullable: 0

## index\_path

    data_type: 'text'
    is_nullable: 1

## arguments

    data_type: 'text'
    is_nullable: 1

# PRIMARY KEY

- ["name"](#name)

# RELATIONS

## sample\_counts

Type: has\_many

Related object: [TearDrop::Model::Result::SampleCount](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/SampleCount.md)

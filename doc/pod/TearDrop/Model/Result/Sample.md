# NAME

TearDrop::Model::Result::Sample

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `samples`

# ACCESSORS

## id

    data_type: 'integer'
    is_auto_increment: 1
    is_nullable: 0
    sequence: 'samples_id_seq'

## forskalle\_id

    data_type: 'integer'
    is_nullable: 1

## description

    data_type: 'text'
    is_nullable: 0

## condition

    data_type: 'text'
    is_foreign_key: 1
    is_nullable: 0

## replicate\_number

    data_type: 'integer'
    is_nullable: 1

## flagged

    data_type: 'boolean'
    default_value: false
    is_nullable: 1

## name

    data_type: 'text'
    is_nullable: 0

# PRIMARY KEY

- ["id"](#id)

# UNIQUE CONSTRAINTS

## `samples_forskalle_id_key`

- ["forskalle\_id"](#forskalle_id)

## `samples_name_key`

- ["name"](#name)

# RELATIONS

## alignments

Type: has\_many

Related object: [TearDrop::Model::Result::Alignment](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Alignment.md)

## condition

Type: belongs\_to

Related object: [TearDrop::Model::Result::Condition](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Condition.md)

## raw\_files

Type: has\_many

Related object: [TearDrop::Model::Result::RawFile](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/RawFile.md)

## sample\_counts

Type: has\_many

Related object: [TearDrop::Model::Result::SampleCount](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/SampleCount.md)

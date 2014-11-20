# NAME

TearDrop::Master::Model::Result::Organism

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)
- [DBIx::Class::InflateColumn::Serializer](https://metacpan.org/pod/DBIx::Class::InflateColumn::Serializer)

# TABLE: `organisms`

# ACCESSORS

## name

    data_type: 'text'
    is_nullable: 0

## scientific\_name

    data_type: 'text'
    is_nullable: 0

## genome\_version

    data_type: 'text'
    is_nullable: 0

## genome\_path

    data_type: 'text'
    is_nullable: 1

# PRIMARY KEY

- ["name"](#name)

# RELATIONS

## gene\_models

Type: has\_many

Related object: [TearDrop::Master::Model::Result::GeneModel](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Master/Model/Result/GeneModel.md)

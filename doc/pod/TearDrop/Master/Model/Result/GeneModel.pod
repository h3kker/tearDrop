# NAME

TearDrop::Master::Model::Result::GeneModel

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)
- [DBIx::Class::InflateColumn::Serializer](https://metacpan.org/pod/DBIx::Class::InflateColumn::Serializer)

# TABLE: `gene_models`

# ACCESSORS

## id

    data_type: 'integer'
    is_auto_increment: 1
    is_nullable: 0
    sequence: 'gene_models_id_seq'

## organism

    data_type: 'text'
    is_foreign_key: 1
    is_nullable: 1

## name

    data_type: 'text'
    is_nullable: 0

## description

    data_type: 'text'
    is_nullable: 1

## sha1

    data_type: 'text'
    is_nullable: 1

## imported

    data_type: 'boolean'
    default_value: false
    is_nullable: 1

## path

    data_type: 'text'
    is_nullable: 0

# PRIMARY KEY

- ["id"](#id)

# UNIQUE CONSTRAINTS

## `gene_models_name_key`

- ["name"](#name)

# RELATIONS

## organism

Type: belongs\_to

Related object: [TearDrop::Master::Model::Result::Organism](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Master/Model/Result/Organism.md)

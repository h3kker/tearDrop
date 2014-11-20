# NAME

TearDrop::Model::Result::GeneModelMapping

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `gene_model_mappings`

# ACCESSORS

## contig

    data_type: 'text'
    is_nullable: 0

## mtype

    data_type: 'text'
    is_nullable: 0

## cstart

    data_type: 'integer'
    is_nullable: 0

## cend

    data_type: 'integer'
    is_nullable: 0

## id

    data_type: 'text'
    is_nullable: 0

## name

    data_type: 'text'
    is_nullable: 1

## parent

    data_type: 'text'
    is_nullable: 1

## additional

    data_type: 'text'
    is_nullable: 1

## gene\_model\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## strand

    data_type: 'text'
    is_nullable: 0

# PRIMARY KEY

- ["id"](#id)
- ["gene\_model\_id"](#gene_model_id)

# RELATIONS

## gene\_model

Type: belongs\_to

Related object: [TearDrop::Model::Result::GeneModel](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/GeneModel.md)

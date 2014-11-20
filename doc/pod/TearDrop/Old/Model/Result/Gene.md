# NAME

TearDrop::Old::Model::Result::Gene

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `genes`

# ACCESSORS

## id

    data_type: 'text'
    is_nullable: 0

## description

    data_type: 'text'
    is_nullable: 1

## best\_homolog

    data_type: 'text'
    is_nullable: 1

## rating

    data_type: 'integer'
    is_nullable: 1

## reviewed

    data_type: 'boolean'
    default_value: false
    is_nullable: 1

## name

    data_type: 'text'
    is_nullable: 1

# PRIMARY KEY

- ["id"](#id)

# RELATIONS

## gene\_tags

Type: has\_many

Related object: [TearDrop::Old::Model::Result::GeneTag](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/GeneTag.md)

## transcripts

Type: has\_many

Related object: [TearDrop::Old::Model::Result::Transcript](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/Transcript.md)

## tags

Type: many\_to\_many

Composing rels: ["gene\_tags"](#gene_tags) -> tag

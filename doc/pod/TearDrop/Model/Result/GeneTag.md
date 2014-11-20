# NAME

TearDrop::Model::Result::GeneTag

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `gene_tags`

# ACCESSORS

## gene\_id

    data_type: 'text'
    is_foreign_key: 1
    is_nullable: 0

## tag

    data_type: 'text'
    is_foreign_key: 1
    is_nullable: 0

# PRIMARY KEY

- ["gene\_id"](#gene_id)
- ["tag"](#tag)

# RELATIONS

## gene

Type: belongs\_to

Related object: [TearDrop::Model::Result::Gene](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Gene.md)

## tag

Type: belongs\_to

Related object: [TearDrop::Model::Result::Tag](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Tag.md)

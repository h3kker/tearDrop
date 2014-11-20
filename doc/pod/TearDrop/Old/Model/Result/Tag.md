# NAME

TearDrop::Old::Model::Result::Tag

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `tags`

# ACCESSORS

## tag

    data_type: 'text'
    is_nullable: 0

## level

    data_type: 'text'
    default_value: 'info'
    is_nullable: 0

## category

    data_type: 'text'
    default_value: 'general'
    is_nullable: 0

# PRIMARY KEY

- ["tag"](#tag)

# RELATIONS

## gene\_tags

Type: has\_many

Related object: [TearDrop::Old::Model::Result::GeneTag](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/GeneTag.md)

## transcript\_tags

Type: has\_many

Related object: [TearDrop::Old::Model::Result::TranscriptTag](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/TranscriptTag.md)

## genes

Type: many\_to\_many

Composing rels: ["gene\_tags"](#gene_tags) -> gene

## transcripts

Type: many\_to\_many

Composing rels: ["transcript\_tags"](#transcript_tags) -> transcript

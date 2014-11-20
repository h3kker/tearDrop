# NAME

TearDrop::Old::Model::Result::Transcript

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `transcripts`

# ACCESSORS

## id

    data_type: 'text'
    is_nullable: 0

## assembly\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## gene

    data_type: 'text'
    is_foreign_key: 1
    is_nullable: 1

## name

    data_type: 'text'
    is_nullable: 1

## nsequence

    data_type: 'text'
    is_nullable: 1

## organism

    data_type: 'text'
    is_foreign_key: 1
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

## description

    data_type: 'text'
    is_nullable: 1

# PRIMARY KEY

- ["id"](#id)

# RELATIONS

## assembly

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::TranscriptAssembly](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/TranscriptAssembly.md)

## blast\_results

Type: has\_many

Related object: [TearDrop::Old::Model::Result::BlastResult](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/BlastResult.md)

## blast\_runs

Type: has\_many

Related object: [TearDrop::Old::Model::Result::BlastRun](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/BlastRun.md)

## gene

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::Gene](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/Gene.md)

## organism

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::Organism](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/Organism.md)

## raw\_counts

Type: has\_many

Related object: [TearDrop::Old::Model::Result::RawCount](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/RawCount.md)

## transcript\_mappings

Type: has\_many

Related object: [TearDrop::Old::Model::Result::TranscriptMapping](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/TranscriptMapping.md)

## transcript\_tags

Type: has\_many

Related object: [TearDrop::Old::Model::Result::TranscriptTag](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/TranscriptTag.md)

## tags

Type: many\_to\_many

Composing rels: ["transcript\_tags"](#transcript_tags) -> tag

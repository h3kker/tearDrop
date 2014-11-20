# NAME

TearDrop::Old::Model::Result::Organism

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

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

Related object: [TearDrop::Old::Model::Result::GeneModel](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/GeneModel.md)

## genome\_alignments

Type: has\_many

Related object: [TearDrop::Old::Model::Result::GenomeAlignment](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/GenomeAlignment.md)

## genome\_mappings

Type: has\_many

Related object: [TearDrop::Old::Model::Result::GenomeMapping](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/GenomeMapping.md)

## transcripts

Type: has\_many

Related object: [TearDrop::Old::Model::Result::Transcript](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/Transcript.md)

# NAME

TearDrop::Old::Model::Result::Alignment

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `alignments`

# ACCESSORS

## id

    data_type: 'integer'
    is_auto_increment: 1
    is_nullable: 0
    sequence: 'alignments_id_seq'

## program

    data_type: 'text'
    is_nullable: 0

## parameters

    data_type: 'text'
    is_nullable: 1

## description

    data_type: 'text'
    is_nullable: 1

## alignment\_date

    data_type: 'timestamp'
    is_nullable: 1

## sample\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## bam\_path

    data_type: 'text'
    is_nullable: 0

## total\_reads

    data_type: 'double precision'
    is_nullable: 1

## mapped\_reads

    data_type: 'double precision'
    is_nullable: 1

## unique\_reads

    data_type: 'double precision'
    is_nullable: 1

## multiple\_reads

    data_type: 'double precision'
    is_nullable: 1

## discordant\_pairs

    data_type: 'double precision'
    is_nullable: 1

# PRIMARY KEY

- ["id"](#id)

# RELATIONS

## genome\_alignment

Type: might\_have

Related object: [TearDrop::Old::Model::Result::GenomeAlignment](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/GenomeAlignment.md)

## sample

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::Sample](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/Sample.md)

## transcriptome\_alignment

Type: might\_have

Related object: [TearDrop::Old::Model::Result::TranscriptomeAlignment](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/TranscriptomeAlignment.md)

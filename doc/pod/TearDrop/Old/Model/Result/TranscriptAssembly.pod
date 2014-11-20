# NAME

TearDrop::Old::Model::Result::TranscriptAssembly

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `transcript_assemblies`

# ACCESSORS

## id

    data_type: 'integer'
    is_auto_increment: 1
    is_nullable: 0
    sequence: 'transcript_assemblies_id_seq'

## name

    data_type: 'text'
    is_nullable: 0

## description

    data_type: 'text'
    is_nullable: 1

## program

    data_type: 'text'
    is_nullable: 0

## parameters

    data_type: 'text'
    is_nullable: 1

## assembly\_date

    data_type: 'timestamp'
    is_nullable: 1

## path

    data_type: 'text'
    is_nullable: 1

## is\_primary

    data_type: 'boolean'
    is_nullable: 0

## sha1

    data_type: 'text'
    is_nullable: 1

## imported

    data_type: 'boolean'
    default_value: false
    is_nullable: 1

# PRIMARY KEY

- ["id"](#id)

# UNIQUE CONSTRAINTS

## `transcript_assemblies_name_key`

- ["name"](#name)

# RELATIONS

## assembled\_files

Type: has\_many

Related object: [TearDrop::Old::Model::Result::AssembledFile](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/AssembledFile.md)

## genome\_mappings

Type: has\_many

Related object: [TearDrop::Old::Model::Result::GenomeMapping](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/GenomeMapping.md)

## transcriptome\_alignments

Type: has\_many

Related object: [TearDrop::Old::Model::Result::TranscriptomeAlignment](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/TranscriptomeAlignment.md)

## transcripts

Type: has\_many

Related object: [TearDrop::Old::Model::Result::Transcript](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/Transcript.md)

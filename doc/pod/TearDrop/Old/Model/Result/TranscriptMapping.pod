# NAME

TearDrop::Old::Model::Result::TranscriptMapping

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `transcript_mappings`

# ACCESSORS

## transcript\_id

    data_type: 'text'
    is_foreign_key: 1
    is_nullable: 0

## genome\_mapping\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## matches

    data_type: 'integer'
    is_nullable: 1

## match\_ratio

    data_type: 'double precision'
    is_nullable: 1

## mismatches

    data_type: 'integer'
    is_nullable: 1

## rep\_matches

    data_type: 'integer'
    is_nullable: 1

## strand

    data_type: 'text'
    is_nullable: 1

## qstart

    data_type: 'integer'
    is_nullable: 1

## qend

    data_type: 'integer'
    is_nullable: 1

## tid

    data_type: 'text'
    is_nullable: 1

## tsize

    data_type: 'integer'
    is_nullable: 1

## tstart

    data_type: 'integer'
    is_nullable: 1

## tend

    data_type: 'integer'
    is_nullable: 1

## blocksizes

    data_type: 'text'
    is_nullable: 1

## qstarts

    data_type: 'text'
    is_nullable: 1

## tstarts

    data_type: 'text'
    is_nullable: 1

# RELATIONS

## genome\_mapping

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::GenomeMapping](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/GenomeMapping.md)

## transcript

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::Transcript](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/Transcript.md)

# NAME

TearDrop::Model::Result::BlastResult

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `blast_results`

# ACCESSORS

## transcript\_id

    data_type: 'text'
    is_foreign_key: 1
    is_nullable: 0

## db\_source\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## source\_sequence\_id

    data_type: 'text'
    is_nullable: 0

## bitscore

    data_type: 'double precision'
    is_nullable: 1

## length

    data_type: 'double precision'
    is_nullable: 1

## pident

    data_type: 'double precision'
    is_nullable: 1

## ppos

    data_type: 'double precision'
    is_nullable: 1

## evalue

    data_type: 'double precision'
    is_nullable: 1

## stitle

    data_type: 'text'
    is_nullable: 1

## organism

    data_type: 'text'
    is_nullable: 1

## nident

    data_type: 'double precision'
    is_nullable: 1

## staxid

    data_type: 'text'
    is_nullable: 1

## slen

    data_type: 'double precision'
    is_nullable: 1

## qlen

    data_type: 'double precision'
    is_nullable: 1

## qseq

    data_type: 'text'
    is_nullable: 1

## sseq

    data_type: 'text'
    is_nullable: 1

## qstart

    data_type: 'integer'
    is_nullable: 1

## qend

    data_type: 'integer'
    is_nullable: 1

## sstart

    data_type: 'integer'
    is_nullable: 1

## send

    data_type: 'integer'
    is_nullable: 1

## gaps

    data_type: 'integer'
    is_nullable: 1

# PRIMARY KEY

- ["transcript\_id"](#transcript_id)
- ["db\_source\_id"](#db_source_id)
- ["source\_sequence\_id"](#source_sequence_id)

# RELATIONS

## db\_source

Type: belongs\_to

Related object: [TearDrop::Model::Result::DbSource](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/DbSource.md)

## transcript

Type: belongs\_to

Related object: [TearDrop::Model::Result::Transcript](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Transcript.md)

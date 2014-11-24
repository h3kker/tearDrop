# NAME

TearDrop::Model::Result::DeResult

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `de_results`

# ACCESSORS

## de\_run\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## contrast\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## transcript\_id

    data_type: 'text'
    is_nullable: 0

## pvalue

    data_type: 'double precision'
    is_nullable: 1

## adjp

    data_type: 'double precision'
    is_nullable: 1

## base\_mean

    data_type: 'double precision'
    is_nullable: 1

## log2\_foldchange

    data_type: 'double precision'
    is_nullable: 1

## flagged

    data_type: 'boolean'
    default_value: false
    is_nullable: 1

# UNIQUE CONSTRAINTS

## `de_results_de_run_id_contrast_id_transcript_id_key`

- ["de\_run\_id"](#de_run_id)
- ["contrast\_id"](#contrast_id)
- ["transcript\_id"](#transcript_id)

# RELATIONS

## contrast

Type: belongs\_to

Related object: [TearDrop::Model::Result::Contrast](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Contrast.md)

## de\_run

Type: belongs\_to

Related object: [TearDrop::Model::Result::DeRun](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/DeRun.md)

## de\_run\_contrast

Type: belongs\_to

Related object: [TearDrop::Model::Result::DeRunContrast](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/DeRunContrast.md)

## transcript

Type: belongs\_to

Related object: [TearDrop::Model::Result::Transcript](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Transcript.md)
Related object: [TearDrop::Model::Result::Gene](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Gene.md)

Note: This is not a foreign key in the database! The `transcript_id` field
refers to a [TearDrop::Model::Result::Gene](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Gene.md) if the count table is aggregated,
to a [TearDrop::Model::Result::Transcript](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Transcript.md) if not. XXX could be replaced with a virtual view.

`add_fk_index =` 0> and `is_foreign_key_constraint` 0> are set to avoid
deployment when creating new projects.

# NAME

TearDrop::Old::Model::Result::DeResult

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

Related object: [TearDrop::Old::Model::Result::Contrast](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/Contrast.md)

## de\_run

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::DeRun](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/DeRun.md)

## de\_run\_contrast

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::DeRunContrast](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/DeRunContrast.md)

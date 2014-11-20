# NAME

TearDrop::Old::Model::Result::BlastRun

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `blast_runs`

# ACCESSORS

## transcript\_id

    data_type: 'text'
    is_foreign_key: 1
    is_nullable: 0

## db\_source\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## parameters

    data_type: 'text'
    is_nullable: 1

## finished

    data_type: 'boolean'
    default_value: false
    is_nullable: 1

## run\_date

    data_type: 'timestamp'
    default_value: current_timestamp
    is_nullable: 1
    original: {default_value => \"now()"}

# PRIMARY KEY

- ["transcript\_id"](#transcript_id)
- ["db\_source\_id"](#db_source_id)

# RELATIONS

## db\_source

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::DbSource](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/DbSource.md)

## transcript

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::Transcript](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/Transcript.md)

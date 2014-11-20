# NAME

TearDrop::Model::Result::DeRunContrast

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `de_run_contrasts`

# ACCESSORS

## de\_run\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## contrast\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## path

    data_type: 'text'
    is_nullable: 0

## parameters

    data_type: 'text'
    is_nullable: 1

## imported

    data_type: 'boolean'
    default_value: false
    is_nullable: 1

## sha1

    data_type: 'text'
    is_nullable: 1

# UNIQUE CONSTRAINTS

## `de_run_contrasts_de_run_id_contrast_id_key`

- ["de\_run\_id"](#de_run_id)
- ["contrast\_id"](#contrast_id)

# RELATIONS

## contrast

Type: belongs\_to

Related object: [TearDrop::Model::Result::Contrast](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Contrast.md)

## de\_results

Type: has\_many

Related object: [TearDrop::Model::Result::DeResult](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/DeResult.md)

## de\_run

Type: belongs\_to

Related object: [TearDrop::Model::Result::DeRun](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/DeRun.md)

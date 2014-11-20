# NAME

TearDrop::Model::Result::RawFile

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `raw_files`

# ACCESSORS

## id

    data_type: 'integer'
    is_auto_increment: 1
    is_nullable: 0
    sequence: 'raw_files_id_seq'

## parent\_file\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 1

## sample\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## read

    data_type: 'integer'
    is_nullable: 0

## description

    data_type: 'text'
    is_nullable: 0

## path

    data_type: 'text'
    is_nullable: 0

## sha1

    data_type: 'text'
    is_nullable: 1

# PRIMARY KEY

- ["id"](#id)

# UNIQUE CONSTRAINTS

## `raw_files_path_key`

- ["path"](#path)

# RELATIONS

## assembled\_files

Type: has\_many

Related object: [TearDrop::Model::Result::AssembledFile](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/AssembledFile.md)

## parent\_file

Type: belongs\_to

Related object: [TearDrop::Model::Result::RawFile](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/RawFile.md)

## raw\_files

Type: has\_many

Related object: [TearDrop::Model::Result::RawFile](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/RawFile.md)

## sample

Type: belongs\_to

Related object: [TearDrop::Model::Result::Sample](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Sample.md)

# NAME

TearDrop::Model::Result::AssembledFile

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `assembled_files`

# ACCESSORS

## assembly\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## raw\_file\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

# RELATIONS

## assembly

Type: belongs\_to

Related object: [TearDrop::Model::Result::TranscriptAssembly](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/TranscriptAssembly.md)

## raw\_file

Type: belongs\_to

Related object: [TearDrop::Model::Result::RawFile](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/RawFile.md)

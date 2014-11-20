# NAME

TearDrop::Model::Result::CountRawFile

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)

# TABLE: `count_raw_files`

# ACCESSORS

## count\_table\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## raw\_file\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

# RELATIONS

## count\_table

Type: belongs\_to

Related object: [TearDrop::Model::Result::CountTable](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/CountTable.md)

## raw\_file

Type: belongs\_to

Related object: [TearDrop::Model::Result::RawFile](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/RawFile.md)

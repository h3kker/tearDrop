# NAME

TearDrop::Master::Model::Result::Tag

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)
- [DBIx::Class::InflateColumn::Serializer](https://metacpan.org/pod/DBIx::Class::InflateColumn::Serializer)

# TABLE: `tags`

# ACCESSORS

## tag

    data_type: 'text'
    is_nullable: 0

## category

    data_type: 'text'
    default_value: 'general'
    is_nullable: 0

## level

    data_type: 'text'
    default_value: 'info'
    is_nullable: 0

# PRIMARY KEY

- ["tag"](#tag)

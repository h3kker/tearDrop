# NAME

TearDrop::Model::Result::Condition

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `conditions`

# ACCESSORS

## name

    data_type: 'text'
    is_nullable: 0

## description

    data_type: 'text'
    is_nullable: 1

# PRIMARY KEY

- ["name"](#name)

# RELATIONS

## contrasts\_base\_conditions

Type: has\_many

Related object: [TearDrop::Model::Result::Contrast](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Contrast.md)

## contrasts\_contrast\_conditions

Type: has\_many

Related object: [TearDrop::Model::Result::Contrast](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Contrast.md)

## samples

Type: has\_many

Related object: [TearDrop::Model::Result::Sample](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Sample.md)

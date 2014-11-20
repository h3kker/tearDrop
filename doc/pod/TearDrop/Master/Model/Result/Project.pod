# NAME

TearDrop::Master::Model::Result::Project

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)
- [DBIx::Class::InflateColumn::Serializer](https://metacpan.org/pod/DBIx::Class::InflateColumn::Serializer)

# TABLE: `projects`

# ACCESSORS

## name

    data_type: 'text'
    is_nullable: 0

## description

    data_type: 'text'
    is_nullable: 1

## status

    data_type: 'text'
    is_nullable: 1

## title

    data_type: 'text'
    is_nullable: 0

## forskalle\_group

    data_type: 'text'
    is_nullable: 0

# PRIMARY KEY

- ["name"](#name)

# RELATIONS

## workqueues

Type: has\_many

Related object: [TearDrop::Master::Model::Result::Workqueue](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Master/Model/Result/Workqueue.md)

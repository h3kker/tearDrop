# NAME

TearDrop::Master::Model::Result::Workqueue

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)
- [DBIx::Class::InflateColumn::Serializer](https://metacpan.org/pod/DBIx::Class::InflateColumn::Serializer)

# TABLE: `workqueue`

# ACCESSORS

## id

    data_type: 'integer'
    is_auto_increment: 1
    is_nullable: 0
    sequence: 'workqueue_id_seq'

## pid

    data_type: 'integer'
    is_nullable: 1

## submit\_date

    data_type: 'timestamp'
    default_value: current_timestamp
    is_nullable: 1
    original: {default_value => \"now()"}

## start\_date

    data_type: 'timestamp'
    is_nullable: 1

## stop\_date

    data_type: 'timestamp'
    is_nullable: 1

## status

    data_type: 'text'
    default_value: 'queued'
    is_nullable: 0

## batch

    data_type: 'boolean'
    default_value: false
    is_nullable: 1

## errmsg

    data_type: 'text'
    is_nullable: 1

## class

    data_type: 'text'
    is_nullable: 0

## task\_object

    data_type: 'text'
    is_nullable: 0

## project

    data_type: 'text'
    is_foreign_key: 1
    is_nullable: 0

# PRIMARY KEY

- ["id"](#id)

# RELATIONS

## project

Type: belongs\_to

Related object: [TearDrop::Master::Model::Result::Project](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Master/Model/Result/Project.md)

# NAME

TearDrop::Old::Model::Result::GenomeMapping

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `genome_mappings`

# ACCESSORS

## id

    data_type: 'integer'
    is_auto_increment: 1
    is_nullable: 0
    sequence: 'genome_mappings_id_seq'

## program

    data_type: 'text'
    is_nullable: 0

## parameters

    data_type: 'text'
    is_nullable: 1

## description

    data_type: 'text'
    is_nullable: 1

## alignment\_date

    data_type: 'timestamp'
    is_nullable: 1

## transcript\_assembly\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## organism\_name

    data_type: 'text'
    is_foreign_key: 1
    is_nullable: 0

## path

    data_type: 'text'
    is_nullable: 0

## sha1

    data_type: 'text'
    is_nullable: 1

## imported

    data_type: 'boolean'
    default_value: false
    is_nullable: 1

# PRIMARY KEY

- ["id"](#id)

# RELATIONS

## organism\_name

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::Organism](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/Organism.md)

## transcript\_assembly

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::TranscriptAssembly](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/TranscriptAssembly.md)

## transcript\_mappings

Type: has\_many

Related object: [TearDrop::Old::Model::Result::TranscriptMapping](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/TranscriptMapping.md)

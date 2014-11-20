# NAME

TearDrop::Model::Result::TranscriptomeAlignment

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `transcriptome_alignments`

# ACCESSORS

## alignment\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

## transcript\_assembly\_id

    data_type: 'integer'
    is_foreign_key: 1
    is_nullable: 0

# PRIMARY KEY

- ["alignment\_id"](#alignment_id)

# RELATIONS

## alignment

Type: belongs\_to

Related object: [TearDrop::Model::Result::Alignment](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/Alignment.md)

## transcript\_assembly

Type: belongs\_to

Related object: [TearDrop::Model::Result::TranscriptAssembly](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Model/Result/TranscriptAssembly.md)

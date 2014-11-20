# NAME

TearDrop::Old::Model::Result::TranscriptTag

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `transcript_tags`

# ACCESSORS

## transcript\_id

    data_type: 'text'
    is_foreign_key: 1
    is_nullable: 0

## tag

    data_type: 'text'
    is_foreign_key: 1
    is_nullable: 0

# PRIMARY KEY

- ["transcript\_id"](#transcript_id)
- ["tag"](#tag)

# RELATIONS

## tag

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::Tag](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/Tag.md)

## transcript

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::Transcript](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/Transcript.md)

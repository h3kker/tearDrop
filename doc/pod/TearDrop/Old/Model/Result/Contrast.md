# NAME

TearDrop::Old::Model::Result::Contrast

# COMPONENTS LOADED

- [DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime)
- [DBIx::Class::Helper::Row::ToJSON](https://metacpan.org/pod/DBIx::Class::Helper::Row::ToJSON)

# TABLE: `contrasts`

# ACCESSORS

## id

    data_type: 'integer'
    is_auto_increment: 1
    is_nullable: 0
    sequence: 'contrasts_id_seq'

## base\_condition

    data_type: 'text'
    is_foreign_key: 1
    is_nullable: 0

## contrast\_condition

    data_type: 'text'
    is_foreign_key: 1
    is_nullable: 0

# PRIMARY KEY

- ["id"](#id)

# RELATIONS

## base\_condition

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::Condition](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/Condition.md)

## contrast\_condition

Type: belongs\_to

Related object: [TearDrop::Old::Model::Result::Condition](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/Condition.md)

## de\_results

Type: has\_many

Related object: [TearDrop::Old::Model::Result::DeResult](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/DeResult.md)

## de\_run\_contrasts

Type: has\_many

Related object: [TearDrop::Old::Model::Result::DeRunContrast](https://github.com/h3kker/tearDrop/blob/master/doc/pod/TearDrop/Old/Model/Result/DeRunContrast.md)

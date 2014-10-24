DROP TABLE IF EXISTS db_sources CASCADE;
CREATE TABLE db_sources (
  id serial primary key,
  dbtype text,
  url text,
  version text,
  downloaded timestamp,
  path text
);

DROP TABLE IF EXISTS organisms CASCADE;
CREATE TABLE organisms (
  name text primary key,
  genome_version text not null,
  genome_path text
);

DROP TABLE IF EXISTS transcripts CASCADE;
CREATE TABLE transcripts (
  id text primary key,
  gene text,
  name text,
  sequence text,
  organism text references organisms(name),
  best_homolog integer,
  flagged boolean default false
);

DROP TABLE IF EXISTS blast_results CASCADE;
CREATE TABLE blast_results (
  transcript_id text not null references transcripts(id),
  parameters text not null,
  db_source_id integer not null references db_sources(id),
  source_sequence_id text not null,
  bitscore float,
  length float,
  pident float,
  ppos float,
  evalue float,
  stitle text,
  organism text
);

DROP TABLE IF EXISTS conditions CASCADE;
CREATE TABLE conditions (
  id serial primary key,
  name text not null unique
);

DROP TABLE IF EXISTS samples CASCADE;
CREATE TABLE samples (
  id serial primary key,
  forskalle_id integer unique,
  description text not null,
  condition_id integer not null references conditions(id),
  replicate_number integer,
  flagged boolean default false
);

DROP TABLE IF EXISTS raw_files CASCADE;
CREATE TABLE raw_files (
  id serial primary key,
  sample_id integer not null references samples(id),
  read integer not null,
  description text not null,
  path text not null unique,
  md5 text
);

DROP TABLE IF EXISTS count_methods CASCADE;
CREATE TABLE count_methods (
  id serial primary key,
  program text not null,
  arguments text,
  index_path text
);

DROP TABLE IF EXISTS count_tables CASCADE;
CREATE TABLE count_tables (
  id serial primary key,
  description text not null unique,
  count_method_id integer not null references count_methods(id),
  subset_of integer references count_tables(id),
  path text not null,
  run_date timestamp
);

DROP TABLE IF EXISTS raw_counts CASCADE;
CREATE TABLE raw_counts (
  id serial primary key,
  count_table_id integer not null references count_tables(id),
  transcript_id text not null references transcripts(id),
  sample_id integer not null references samples(id),
  count float,
  tpm float,
  include boolean default true
);

DROP TABLE IF EXISTS contrasts CASCADE;
CREATE TABLE contrasts (
  id serial primary key,
  base_condition_id integer not null references conditions(id),
  contrast_condition_id integer not null references conditions(id)
);

DROP TABLE IF EXISTS de_runs CASCADE;
CREATE TABLE de_runs (
  id serial primary key,
  description text not null unique,
  run_date timestamp,
  parameters text,
  count_table_id integer not null references count_tables(id)
);

DROP TABLE IF EXISTS de_results CASCADE;
CREATE TABLE de_results (
  de_run_id integer not null references de_runs(id),
  contrast_id integer not null references contrasts(id),
  pvalue float,
  adjp float,
  base_mean float,
  log2_foldchange float,
  flagged boolean default false
);


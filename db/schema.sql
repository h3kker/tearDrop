DROP TABLE IF EXISTS db_sources CASCADE;
CREATE TABLE db_sources (
  id serial primary key,
  name text not null unique,
  description text not null unique,
  dbtype text,
  url text,
  version text,
  downloaded timestamp,
  path text
);

DROP TABLE IF EXISTS organisms CASCADE;
CREATE TABLE organisms (
  name text primary key,
  scientific_name text not null,
  genome_version text not null,
  genome_path text
);

DROP TABLE IF EXISTS gene_models CASCADE;
CREATE TABLE gene_models (
  organism text references organisms(name),
  path text
);

DROP TABLE IF EXISTS transcript_assemblies CASCADE;
CREATE TABLE transcript_assemblies (
  id serial primary key,
  name text not null unique,
  description text,
  program text not null,
  parameters text,
  assembly_date timestamp,
  path text,
  is_primary boolean not null
); 

DROP TABLE IF EXISTS genes CASCADE;
CREATE TABLE genes (
  id text primary key,
  description text,
  best_homolog integer,
  flagged boolean default false
);

DROP TABLE IF EXISTS transcripts CASCADE;
CREATE TABLE transcripts (
  id text primary key,
  assembly_id integer not null references transcript_assemblies(id),
  gene text references genes(id),
  name text,
  nsequence text,
  organism text references organisms(name),
  best_homolog integer,
  flagged boolean default false
);
create index transcripts_gene_idx on transcripts(gene);

DROP TABLE IF EXISTS blast_runs CASCADE;
CREATE TABLE blast_runs (
  transcript_id text not null references transcripts(id),
  db_source_id integer not null references db_sources(id),
  parameters text,
  PRIMARY KEY (transcript_id, db_source_id)
);

DROP TABLE IF EXISTS blast_results CASCADE;
CREATE TABLE blast_results (
  transcript_id text not null references transcripts(id),
  db_source_id integer not null references db_sources(id),
  source_sequence_id text not null,
  bitscore float,
  length float,
  nident float,
  pident float,
  ppos float,
  evalue float,
  staxid text,
  qlen float,
  slen float,
  stitle text,
  organism text,
  FOREIGN KEY (transcript_id, db_source_id) references blast_runs (transcript_id, db_source_id)
);

DROP TABLE IF EXISTS conditions CASCADE;
CREATE TABLE conditions (
  name text primary key,
  description text
);

DROP TABLE IF EXISTS samples CASCADE;
CREATE TABLE samples (
  id serial primary key,
  forskalle_id integer unique,
  description text not null,
  condition text not null references conditions(name),
  replicate_number integer,
  flagged boolean default false
);

DROP TABLE IF EXISTS raw_files CASCADE;
CREATE TABLE raw_files (
  id serial primary key,
  parent_file_id integer references raw_files(id),
  sample_id integer not null references samples(id),
  read integer not null,
  description text not null,
  path text not null unique,
  md5 text
);

DROP TABLE IF EXISTS assembled_files CASCADE;
CREATE TABLE assembled_files (
  assembly_id integer not null references transcript_assemblies(id),
  raw_file_id integer not null references raw_files(id)
);

DROP TABLE IF EXISTS count_methods CASCADE;
CREATE TABLE count_methods (
  name text primary key,
  program text not null,
  index_path text,
  arguments text
);

DROP TABLE IF EXISTS count_tables CASCADE;
CREATE TABLE count_tables (
  id serial primary key,
  name text not null unique,
  description text,
  aggregate_genes bool default false,
  subset_of integer references count_tables(id)
);

DROP TABLE IF EXISTS sample_counts CASCADE;
CREATE TABLE sample_counts (
  id serial primary key,
  sample_id integer not null references samples(id),
  count_method text not null references count_methods(name),
  call text,
  path text not null,
  mapped_ratio float,
  run_date timestamp
);


DROP TABLE IF EXISTS raw_counts CASCADE;
CREATE TABLE raw_counts (
  id serial primary key,
  transcript_id text not null references transcripts(id),
  sample_count_id integer not null references sample_counts(id),
  count float,
  tpm float,
  UNIQUE (transcript_id, sample_count_id)
);

DROP TABLE IF EXISTS table_counts CASCADE;
CREATE TABLE table_counts (
  count_table_id integer not null references count_tables(id),
  raw_count_id integer not null references raw_counts(id),
  UNIQUE (count_table_id, raw_count_id)
);

DROP TABLE IF EXISTS contrasts CASCADE;
CREATE TABLE contrasts (
  id serial primary key,
  base_condition text not null references conditions(name),
  contrast_condition text not null references conditions(name)
);

DROP TABLE IF EXISTS de_runs CASCADE;
CREATE TABLE de_runs (
  id serial primary key,
  description text not null unique,
  run_date timestamp,
  parameters text,
  path text,
  count_table_id integer not null references count_tables(id)
);

DROP TABLE IF EXISTS de_run_contrasts CASCADE;
CREATE TABLE de_run_contrasts (
  de_run_id integer not null references de_runs(id),
  contrast_id integer not null references contrasts(id),
  path text not null,
  parameters text,
  UNIQUE(de_run_id, contrast_id)
);

DROP TABLE IF EXISTS de_results CASCADE;
CREATE TABLE de_results (
  de_run_id integer not null references de_runs(id),
  contrast_id integer not null references contrasts(id),
  transcript_id text not null,
  pvalue float,
  adjp float,
  base_mean float,
  log2_foldchange float,
  flagged boolean default false,
  UNIQUE(de_run_id, contrast_id, transcript_id),
  FOREIGN KEY (de_run_id, contrast_id) REFERENCES de_run_contrasts(de_run_id, contrast_id)
);
create index de_result_transcript_id_idx on de_results(transcript_id);


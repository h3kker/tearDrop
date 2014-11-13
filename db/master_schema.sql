DROP TABLE IF EXISTS projects CASCADE;
CREATE TABLE projects (
  name text primary key,
  title text not null unique,
  description text,
  forskalle_group text not null,
  status text
);


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

INSERT INTO db_sources (name, description, dbtype, url, version, downloaded, path) VALUES 
  ('refset_fungi', 'RefSeq Fungi', 'blastp', 'ftp://ftp.ncbi.nlm.nih.gov/refseq/release/fungi', '67', '2014-10-01', '/groups/csf-ngs/data/blast/refseq_fungi.fasta'),
  ('refset_plant', 'RefSeq Plant', 'blastp', 'ftp://ftp.ncbi.nlm.nih.gov/refseq/release/fungi', '67', '2014-10-01', '/groups/csf-ngs/data/blast/refseq_plant.fasta'),
  ('brachy_cyc', 'BrachyCyc', 'blastp', 'ftp://ftp.plantcyc.org/Pathways/BLAST_sets/brachypodiumcyc_enzymes.fasta', 'unknown', '2014-10-23', '/groups/csf-ngs/data/blast/brachypodiumcyc_enzymes.fasta'),
  ('plant_cyc', 'PlantCyc', 'blastp', 'ftp://ftp.plantcyc.org/Pathways/BLAST_sets/reference_enzymes.3.0.fasta', '3.0', '2014-10-23', '/groups/csf-ngs/data/blast/plantcyc_enzymes.fasta'),
  ('tair10_prot', 'TAIR10 Proteins', 'blastp', 'ftp://ftp.arabidopsis.org/home/tair/Sequences/blast_datasets/TAIR10_blastsets/TAIR10_pep_20101214_updated', '20101214', '2014-10-23', '/groups/csf-ngs/data/blast/TAIR10_pep_20101214_updated.fasta'),
  ('ncbi_cdd', 'NCBI Conserved Domain Database', 'rpsblast', 'ftp://ftp.ncbi.nih.gov/pub/mmdb/cdd/cdd.tar.gz', '3.12', '2014-10-24', '/groups/csf-ngs/data/blast/cdd/Cdd')
;

DROP TABLE IF EXISTS workqueue CASCADE;
CREATE TABLE workqueue (
  id serial primary key,
  project text not null references projects(name),
  pid integer,
  submit_date timestamp default current_timestamp,
  start_date timestamp,
  stop_date timestamp,
  status text not null default 'queued',
  batch boolean default false,
  errmsg text,
  class text not null,
  task_object text not null
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
  id serial primary key,
  organism text references organisms(name),
  name text not null unique,
  description text,
  sha1 text,
  imported boolean default false,
  path text NOT NULL
);

DROP TABLE IF EXISTS tags CASCADE;
CREATE TABLE tags (
  tag text primary key,
  category text not null default 'general',
  level text not null default 'info'
);

INSERT INTO tags (tag, category, level) VALUES
  ('bad assembly', 'general', 'danger'),
  ('good assembly', 'general', 'success'),
  ('interesting', 'general', 'success'),
  ('possible chimera', 'general', 'danger'),
  ('possible fusion', 'general', 'danger'),
  ('short', 'general', 'warning'),
  ('good coverage', 'coverage', 'success'),
  ('low overall', 'coverage', 'warning'),
  ('low 5p', 'coverage', 'warning'),
  ('low 3p', 'coverage', 'warning'),
  ('dip', 'coverage', 'warning'),
  ('multiple dips', 'coverage', 'warning'),
  ('uneven', 'coverage', 'warning'),
  ('very uneven', 'coverage', 'warning'),
  ('many errors', 'coverage', 'warning'),
  ('good homologs', 'homology', 'success'),
  ('bad homolog support', 'homology', 'warning'),
  ('no annotations', 'homology', 'warning'),
  ('no homologs', 'homology', 'danger'),
  ('maybe intron', 'mapping', 'warning'),
  ('unmapped', 'mapping', 'danger'),
  ('lots of mappings', 'mapping', 'warning'),
  ('many orthologs', 'mapping', 'info'),
  ('bad mapping', 'mapping', 'danger')
;


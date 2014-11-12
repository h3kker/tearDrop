# Development Roadmap 

## bugs/urgent

- DONE "loading" feedback (more or less)
- hide alignment view when unavailable
- set url path on de run selection
- deal with multiple alignments => selection, define "favorite"
- refactor old worker to backup worker, or e.g. for batch blast
- search by transcript/gene fields in de result table

## big stuff

- multiple projects: master database with separate dbs for projects
- blast search in transcript assemblies (see also reciprocal best hit)
- DONE import GFF files with genome annotations
- DONE job manager
  * DONE via db table
  * DONE worker process started on request
  * DONE respawn worker process on fail
  * DONE signal worker with fifo, use fifo to check if worker alive, restart if no response
  * race condition safety: provide one fifo per worker (tmpdir?), select task for update in transaction; 
  * cannot start job with post_processing command (does not survive de/serialisation)
  * one dedicated worker process started separately? comms with REST?
- refactor transcript/gene ids - use surrogate key (internal id) to support multiple assemblies per db (with same assembler, trinity would produce id collisions)

## visualisation

- genomic alignments
  - display gff annotations and blat mappings
  - (limited!) zooming
  - display coverage, split by strand, with mismatches
- multiple sequence alignment viewer
  - blast results
  - mafft results for transcripts
- de result diagnostic plots (volcano, MA)
- alignment overviews
  - mapping %, dis/concordant pairings; maybe idxstats
- 

use/extend https://github.com/WealthBar/angular-d3?

## automated annotation workflow

- DONE run blast in background
  * DONE annotate genes and transcripts with best hits
  * DONE set no/good/bad homology tags
- XXX reciprocal best hit
- transfer transcript annotations to genes
- analyze coverage
  * categorize high/low
  * look for dips
  * possible introns (via genomic coverage, use annotation where available)

## manual curation

- DONE transcript view: integrate into gene view, move transcript alignment view there
- display more details for genomic mapping
- DONE split tags into categories, 
  - display categorized tags in each tab
  - find good space for alignment/mapping tags
  - only general tags on top?
- transfer annotations from transcript to gene
- generate rating from tags

## nice to have

- overview page (general assembly stats)
- sample, alignments, assembly pages
- data exports?
- transcript sequence viewer (highlight start/stop codons, splice junctions (from genome mapping) etc)

### data import

- via web?
- create/import stats for 
  - DONE alignments (tophat, star, bowtie)
  - count tables
  - samples (raw files)
  - genome mappings

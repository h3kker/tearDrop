# Development Roadmap 

## bugs/urgent

- XXX "loading" feedback 
- disable alignment view when unavailable
- set url path on de run selection
- deal with multiple alignments => selection, define "favorite"
- refactor old worker to backup worker, might be useful to keep around

## big stuff

- multiple projects: master database with separate dbs for projects
- blast against transcript assemblies (see also reciprocal best hit)
- DONE job manager
  * DONE via db table
  * DONE worker process started on request
  * DONE respawn worker process on fail
  * DONE signal worker with fifo, use fifo to check if worker alive, restart if no response
  * race condition safety: provide one fifo per worker (tmpdir?), select task for update in transaction
  * cannot start job with post_processing command (does not survive de/serialisation)
- refactor transcript/gene ids - use surrogate key (internal id) to support multiple assemblies per db (with same assembler, trinity would produce id collisions)

## visualisation

- multiple sequence alignment viewer
- blast alignment viewer
- blat mappings/gff files in genome alignment
- de result diagnostic plots (volcano, MA)

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
  * possible introns (via genomic coverage)

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

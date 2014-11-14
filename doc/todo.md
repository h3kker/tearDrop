# Development Roadmap 

## bugs/urgent

- "loading" feedback, error handling ($http interceptor?)
- hide alignment view when unavailable
- set url path on de run selection
- deal with multiple alignments => selection, define "favorite"
- refactor old worker to backup worker, or e.g. for batch blast
- search by transcript/gene fields in de result table
- assembly selection in views
- XXX reciprocal best hit
- XXX transcript alignment meta: field for "needs prefix"

## big stuff

- DONE multiple projects: master database with separate dbs for projects
  - DONE create template and provide scripts to setup project db
- blast search in transcript assemblies (see also reciprocal best hit)
  - extract ref seq from blast db 
  - fasta text field
- DONE import GFF files with genome annotations
- job manager
  * DONE via db table
  * DONE worker process started on request
  * DONE respawn worker process on fail
  * DONE signal worker with fifo, use fifo to check if worker alive, restart if no response
  * DONE use YAML to de/serialize tasks
  * race condition safety: provide one fifo per worker (tmpdir?), select task for update in transaction; 
  * cannot start job with post_processing command (does not survive de/serialisation)
  * one dedicated worker process started separately? comms with REST?
- DONE refactor transcript/gene ids - use surrogate key (internal id) to support multiple assemblies per db (with same assembler, trinity would produce id collisions) (in the end concat id with assembly-specific id prefix)
- transcript-transcript relationships for assembly comparisons

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
  * mapping percent, dis/concordant pairings; maybe idxstats

use/extend https://github.com/WealthBar/angular-d3? or not.

## automated annotation workflow

- DONE run blast in background
  * DONE annotate genes and transcripts with best hits
  * DONE set no/good/bad homology tags
- transfer transcript annotations to genes
- analyze coverage
  * categorize high/low
  * look for dips
  * possible introns (via genomic coverage, use annotation where available)
- generate rating from tags

## manual curation

- DONE transcript view: integrate into gene view, move transcript alignment view there
- display more details for genomic mapping
  - DONE external annotations (GFF)
  - matching parts, gaps, etc.
  - comparison with CDS/exon from external GFFs
  - weird things like transcripts mapped over several 100 kb
- DONE split tags into categories, 
  - display categorized tags in each tab
  - find good space for alignment/mapping tags
  - only general tags on top?
- transfer annotations from transcript to gene
- DONE liftover annotations from transcripts, between projects

## data import

- via web?
  - local files: submit to worker
  - upload: might be complicated; maybe not via browser, curl/wget? should have a resume. 
- suppport g/bzip
- create/import stats for 
  - DONE alignments (tophat, star, bowtie)
  - count tables
  - samples (raw files)
  - genome mappings

## nice to have

- overview page (general assembly stats)
- sample, alignments, assembly pages (necessary for data import via web)
- data exports?
- transcript sequence viewer (highlight start/stop codons, splice junctions (from genome mapping) etc)
- refactor transcript and gene model mappings to generic genomic mapping; use maybe BioPerl for gff/psl import for common interface
- use bioperl to run/parse blast?
- look at bioperl interfaces to go annotations and online databases
- faster alignment parsing: replace samtools with bioperl samtools? (-> slower, but maybe some trickery with mmap()ing, might use too much RAM); or merge sam alignments and use read groups to keep track of original file.
- schema versioning


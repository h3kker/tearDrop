# Development Roadmap 

## bugs/urgent

- "loading" feedback, error handling ($http interceptor?)
- deal with multiple alignments => selection, define "favorite"
- search by transcript/gene fields in de result table
- XXX unroll mappings to annotations, don't load them separately for each map
- XXX reciprocal best hit
- DONE set url path on de run selection
- DONE assembly selection in views
- DONE transcript alignment meta: field for "use_original_id"
- DONE alignment disappears when gene/transcript is saved....
- DONE GFF3 parsing to tree: do not require gene as root, should be able to use CDS and exon

## big stuff

- blast search in transcript assemblies (see also reciprocal best hit)
  - pick ref seq from installed blast db 
  - input text field for any fasta
  - blastx/tblastx/blastn etc
- transcript-transcript relationships for assembly comparisons
- DONE import GFF files with genome annotations
- DONE refactor transcript/gene ids - use surrogate key (internal id) to support multiple assemblies per db (with same assembler, trinity would produce id collisions) (in the end concat id with assembly-specific id prefix)
- DONE multiple projects: master database with separate dbs for projects
  - DONE create template and provide scripts to setup project db

## job dispatcher

- cannot start job with post_processing command (does not survive de/serialisation)??
- "in memory" dispatcher for bulk jobs? submit to redis/db queue and have dedicated dispatcher?
- DONE start only one work dispatcher, controlled with PID file
  - XXX (re)start with web server, but not with script jobs, move to before hook again?
  - XXX stop with web server?
  - DONE respawn worker process on fail
- DONE Redis Queue 
  - XXX figure out Storable f*ckup in upstream module? replace with YAML?
- DONE Database Queue
  - DONE via db table
  - DONE FIFO signalling on new jobs
  - DONE FIFO signalling optional (fallback on polling)
  - DONE use YAML to de/serialize tasks
  - select for update (make sure no other worker picks up same task)

## visualisation

- genomic alignments
  - interactive annotations
  - reload annotations on zoom
  - DONE display gff annotations and blat mappings
  - DONE zoom out (a little) 
  - DONE focus on other annotations in area
  - DONE zooming 
  - DONE display coverage, split by strand, with mismatches
- multiple sequence alignment viewer
  - blast results
  - mafft results for transcripts
- de result diagnostic plots (volcano, MA)
- alignment overviews
  * mapping percent, dis/concordant pairings; maybe idxstats

use/extend https://github.com/WealthBar/angular-d3? or not. Highcharts FTW!!!

## automated annotation workflow

- transfer/sync annotations between transcripts and genes
- use/transfer/compare with external annotations
  * bulk overlapping
  * make table with relationship between genes/transcripts and genes/mRNA from ann
  * transfer annotations
- analyze genome mapping
  * intron sizes
  * coverage
  * identity
- create features for transcripts (UTR, reading frames, CDS, ...)
- analyze coverage
  * categorize high/low
  * look for dips
  * possible introns (via genomic coverage, use annotation where available)
- generate rating from tags
- DONE run blast in background
  * DONE annotate genes and transcripts with best hits
  * DONE set no/good/bad homology tags

## manual curation

- display more details for genomic mapping
  - matching parts, gaps, etc.
  - comparison with CDS/exon from external GFFs
  - feature link table
  - DONE filtering
    - DONE display only useful genome mappings 
    - userdefined criteria!
    - DONE show something when there''s no valid mapping
    - show bad mappings
    - point out weird things like transcripts mapped over several 100 kb
- transfer annotations from transcript to gene
- DONE split tags into categories, 
  - display categorized tags in each tab
  - find good space for alignment/mapping tags
  - only general tags on top?
- show current tag counts in overview page
- DONE liftover annotations from transcripts, between projects
- DONE transcript view: integrate into gene view, move transcript alignment view there
- DONE external annotations (GFF)

## Differential Expression

- overview over de runs, parameters, contrasts

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
- use Text::CSV or similar for table import

## nice to have

- overview page (general assembly stats)
- sample, alignments, assembly pages (necessary for data import via web)
- data exports?
- transcript sequence viewer (highlight start/stop codons, splice junctions (from genome mapping) etc)
- DONE refactor transcript and gene model mappings to generic genomic mapping; use maybe BioPerl for gff/psl import for common interface (at least in annotation JSON)
- use bioperl to run/parse blast?
- look at bioperl interfaces to go annotations and online databases
- faster alignment parsing: replace samtools with bioperl samtools? (-> slower, but maybe some trickery with mmap()ing, might use too much RAM); or merge sam alignments and use read groups to keep track of original file.
- schema versioning, automated migration to new schema
- fix mess with mappings: set default to "only useful", find good space (pbly $obj->mappings); all mappings only on demand ($obj->transcript_mappings DBIx accessor); can we overload accessor and reverse behavior?
- integrate genome mappings and external annotations, they have many things in common

## djamei specific

- align to transcripts with bwa?
- DONE replace ustilago assembly fasta ids with chrnames from gertrud
  - DONE in genome mapping
  - DONE in alignments
  - DONE in fasta (duh)
  - ...?
- DONE align to usti with star?
- DONE import getrud gff for usti

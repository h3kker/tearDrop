# Development Roadmap 

## Mojolicious migration

- set access control/no-cache cookie!
- command line tools
  - DONE run_blast
  - import_metadata
  - deploy_project (---> use dbix migration??)
  - import_transcript_meta.pl??
  - transfer_annotations??

## bugs/urgent

- notifications about jobs don't work so well
- import aligner/parameters from bam header
- tag admin (merge, change, ...)
- XXX show error on de page when de run result not yet imported
- deal with multiple alignments => selection, define "favorites"?
- select primary assembly as default for transcript list, reverse blast, etc...
- truncate fasta titles on export (long cdd descriptions)
- DONE fix annotation in genome alignment viewer: arearange + plotbands!
- DONE reciprocal best hit
- DONE genome alignment zoom
- DONE search by transcript/gene fields in de result table
- DONE unroll mappings to annotations, don't load them separately for each map
- DONE set url path on de run selection
- DONE assembly selection in views
- DONE transcript alignment meta: field for "use_original_id"
- DONE alignment disappears when gene/transcript is saved....
- DONE GFF3 parsing to tree: do not require gene as root, should be able to use CDS and exon
- DONE "loading" feedback ($http interceptor? -> use angular-busy)

## big stuff

- blast search in transcript assemblies (see also reciprocal best hit)
  - input text field for any fasta (where?)
  - (blastx)/tblastn/blastn etc
  - ??? promote blast runs table (include parameters etc), also track reverse blast runs
  - DONE pick ref seq from installed blast db 
  - DONE where to display/interface?
  - DONE currently two tables? (seems ok for now)
- sample can belong to many conditions
- relationships between transcripts and annotations (graph structure)
  - edge evidence types: sequence clustering/alignment; genome mapping; homology(blast)
  - edge categories: match (redundant_to), partial overlap (prefix, postfix, infix_longer, infix_shorter), qualitative (intron, cds, splice_variant, split, same_gene)
  - transcript-transcript relationships for assembly comparisons
  - transcript-annotation relationships (enough to do it via genome mappings?)
  - transcript-homolog-reciprocal best hit
  - DONE use bwa mem instead of blat/cdhit/uclust?? does not work
- DONE import GFF files with genome annotations
- DONE refactor transcript/gene ids - use surrogate key (internal id) to support multiple assemblies per db (with same assembler, trinity would produce id collisions) (in the end concat id with assembly-specific id prefix)
- DONE multiple projects: master database with separate dbs for projects
  - DONE create template and provide scripts to setup project db

## job dispatcher

- DONE cannot start job with post_processing command - replace with method do_post_processing, have option to enable calling. less flexible, but so what.
- "in memory" dispatcher for bulk jobs? submit to redis/db queue and have dedicated dispatcher?
- DONE start only one work dispatcher, controlled with PID file
  - DONE (re)start with web server, but not with script jobs, move to before hook again?
  - XXX stop with web server?
  - DONE respawn worker process on fail
- DONE Redis Queue 
  - XXX job status updates do not always work?!
- DONE Database Queue
  - select for update (make sure no other worker picks up same task)
  - XXX test me more (w/ mojolicious)
  - use notify/listen on postgres, fallback to pipe/polling otherwise
  - DONE via db table
  - DONE FIFO signalling on new jobs
  - DONE FIFO signalling optional (fallback on polling)
  - DONE use YAML to de/serialize tasks

## visualisation

- genomic alignments
  - XXX annotations need refactoring 
  - interactive annotations
  - DONE reload annotations on zoom
  - DONE display gff annotations and blat mappings
  - DONE zoom out (a little) 
  - DONE focus on other annotations in area
  - DONE zooming 
  - DONE display coverage, split by strand, with mismatches
- multiple sequence alignment viewer
  - update dynamically on what is displayed (esp blast results)
  - vis. similarities
  - DONE blast results
  - DONE mafft results for transcripts
- de result diagnostic plots (volcano, MA)
- alignment overviews
  * mapping percent, dis/concordant pairings; maybe idxstats

use/extend https://github.com/WealthBar/angular-d3? or not. Highcharts FTW!!!

## automated annotation workflow

- bulk blast
  * DONE annotate genes and transcripts with best hits
  * DONE set no/good/bad homology tags
  - DONE get to work with new queue
  - DONE configure annotate, evalue, max_target_seq, etc.
  - DONE reset tags (remove no/bad homologs with subsequent blast finds something)
  - DONE bulk blast import
  - define favorite db for autoannotate, use others as fallback
  - consider hit coverage (sometimes very bad with low e-value)
  - use CDD only for description?
- reciprocal best hit annotation
  - DONE bulk blast import
  - calculate forward/reverse ranks for blast hits
  - set tags: reciprocal best hit/reciprocal good hit/reciprocal bad hit/reciprocal no hit
- transfer/sync annotations between transcripts and genes
- use/transfer/compare with external annotations
  * bulk overlapping (only genome mapping? how to cluster?)
  * make table with relationship between genes/transcripts and genes/mRNA from ann
  * transfer annotations
- analyze genome mapping
  * DONE set no/good/many mapping tags
  * intron sizes
  * coverage
  * identity
  * create fields for various metrics with overloaded accessors!
  * filtering in database (faster!)
  * fix mess with mappings: set default to "only useful", find good space (pbly
    $obj->mappings); all mappings only on demand ($obj->transcript_mappings DBIx
    accessor); can we overload accessor and reverse behavior?
- create features for transcripts (UTR, reading frames, CDS, ...)
- analyze coverage
  * categorize high/low
  * look for dips
  * possible introns (via genomic coverage, use annotation where available)
- generate rating from tags

## manual curation

- display more details for genomic mapping
  - matching parts, gaps, etc.
  - comparison with CDS/exon from external GFFs
  - feature link table
  - DONE filtering
    - DONE display only useful genome mappings 
    - userdefined criteria!
    - DONE show something when there''s no valid mapping
    - show bad mappings on demand
    - point out weird things like transcripts mapped over several 100 kb
- reverse blast overview page? search for external sequence identifiers?
- transfer annotations from transcript to gene and back
- DONE split tags into categories, 
  - DONE display categorized tags in each tab
  - DONE find good space for alignment/mapping tags
  - only general tags on top?
- show current tag counts in overview page
- refactor 1000 tag lists to tag display directive
- DONE refactor 1000 tag forms to tag edit directive
- DONE liftover annotations from transcripts, between projects
- DONE transcript view: integrate into gene view, move transcript alignment view there
- DONE external annotations (GFF)

## Differential Expression

- overview over de runs, parameters, contrasts
- filtering based on raw/normalized counts
  - (at least one, all) (sample count, mean count for cond) > threshold
  

## data import

- via web?
  - local files: submit to worker
  - upload: might be complicated; maybe not via browser, curl/wget? should have a resume. 
- suppport g/bzip
- create/import stats for 
  - DONE alignments (tophat, star, bowtie)
  - count tables
    interesting: raw counts, fpkm/tpm, normalized counts, per sample
    needed for filtering, put into db after all? 
  - samples (raw files)
  - genome mappings
- blast import
  - DONE reverse blast table
  - forward blast table (test me!)
  - multiple formats
- use Text::CSV or similar for table import
- YAML/JSON import for tables (also export?) 
- blast db location for transcript assembly/automatically create blast db

## nice to have

- overview pages 
  - DONE assemblies with basic stats **still needs edit**
  - DONE samples with edit
  - DONE annotations **still needs edit**
  - DONE genome alignments **still needs edit**
    - alignment overview graph 
  - transcript alignments
  - meta: organisms, blast dbs, conditions
- data exports?
- transcript sequence viewer (highlight start/stop codons, splice junctions (from genome mapping, annotations), low complexity/repeats, etc)
- DONE refactor transcript and gene model mappings to generic genomic mapping; use maybe BioPerl for gff/psl import for common interface (at least in annotation JSON)
- use bioperl to run/parse blast?
- faster alignment parsing: replace samtools with bioperl samtools? (-> slower, but maybe some trickery with mmap()ing, might use too much RAM); or merge sam alignments and use read groups to keep track of original file.
- schema versioning, automated migration to new schema
  dbix::class::migration or DBIx::Class::DeploymentHandler, figure it out
- integrate genome mappings and external annotations, they have many things in common
- users (+external auth)
- history logging
- better engineering of "loading" message
- central error handling for API calls
- look at bioperl interfaces to go annotations and online databases
- async route handlers for long running stuff
- stream fasta exports? only if they're big?
- minion backend + worker?
  stick to mine for now, minion cannot do Task classes?? also needs Mojolicious::Plugin::Pg

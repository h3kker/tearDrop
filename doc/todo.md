# Development Roadmap 

## bugs/urgent

- XXX "loading" feedback 
- disable alignment view when unavailable
- set url path on de run selection

## big stuff

- multiple projects: master database with separate dbs for projects
- job manager
  * via db table
  * worker process started on request
  * how to signal new jobs?
- refactor transcript/gene ids - use internal id to support multiple assemblies per db

## visualisation

- multiple sequence alignment viewer
- blast alignment viewer
- blat mappings/gff files in genome alignment
- de result diagnostic plots (volcano, MA)

use/extend https://github.com/WealthBar/angular-d3?

## automated annotation workflow

- DONE run blast in background
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
- sample, alignments, assebmly pages
- data exports?
- transcript sequence viewer (highlight start/stop codons, splice junctions (from genome mapping) etc)

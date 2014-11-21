# TearDrop Data

Your TearDropping experience starts only after a lot of tears have been dropped
by a bioinformatician who needs to generate a few files. Maybe some of the
stuff can be moved inside TearDrop as a pipeline, but we *do not want to build
another galaxy*.

## Important Considerations

At the moment, some files are imported into the database, but some have to be
readable by the TearDrop web server directly. This has to change.

Some things have to be on the file system, like the BLAST databases. But we
particularly do not want to have files that are large and a pain to store in a
relational database and don't need to queried and filtered on a regular basis.
So it's good to import GFF and PSL files (because we want to have subsets of
them all the time).

Other things can stay on the file system, for all we care, like count tables
and alignments (Gigabytes of data!). At first, I thought count tables should go
into the database, but the schema is a disaster and results in millions of
rows. For the count tables it's better to calculate some summary stats and show
these and not care so much about the raw counts (or whateverPM).

Maybe at some point this stuff could instead go into a
[Redis](http://redis.io/) key/value store, which seems much better suited for
it than the database (but what about RAM? is MongoDB better?).  Especially the
alignments, since it (naturally) takes a few seconds to extract regions with
`samtools mpileup`, even though it's amazingly blazingly fast, considering the
amount of data.

### Changing File Locations

Of course you need to update the paths in the database. For imported files, a
SHA1 checksum is calculated so that they are not re-imported even when the path
changes.

## Supported Data Files

### Assembly

> Please seriously consider giving your assembled transcripts new IDs, like a
> prefix. Otherwise things can get messy when comparing multiple assemblies.
> TearDrop can do this on importing, but then we have to convert to original ids
> in a lot of other files if they were created with the "raw" ids.

- FASTA files

Trinity output will be automatically parsed for gene/transcript associations
via the fasta id field. 

### Alignments

- BAM files (coordinate-sorted, indexed) from any aligner (they stay on the file system)
- diagnostic output by `tophat`, `STAR` and `bowtie2` (these are imported) XXX bowtie! XXX bwa!

### Genome Annotations

- GFF files. These can have `gene` annotations, but if they should show up in
  genome alignments, they absolutely should have `mRNA` lines, ideally linked
  to `gene`s via the `parent_id` field. Optionally the `mRNA`s can be composed
  of `exon` or `CDS` (the latter is only displayed if the `mRNA` has no `exon`
  annotation), again linked via the `parent_id` field.
- XXX no GTF?

### Transcript to Genome mappings

- PSL files produced by blat
- XXX no GFF/GTF yet!

### BLAST 

Currently tested: `ncbi-blast 2.2.29+`. Support for databases:

- protein
- rpsblast (eg. Conserved Domain Database)

The databases stay on the file system (well, duh).

### Differential Expression Analyses

- DeSeq2 results as tab separated values
- ... there should be much more here, but there isn't!

After you do your DE analysis in R, export the results like this:

    > dds.r <- results(dds, contrast = c("exp", "crazy mutant", "boring wildtype"))
    > tmp.df <- cbind(transcript = rownames(dds.r), data.frame(dds.r)) 
    > write.table(tmp.df, file = "crazy_vs_boring.tab", sep = "\t", quote = F, row.names = F)

## Providing Meta Data

Since the web interface is still very rudimentary, use CSV files to tell us
what's what and who's who and where the cow can find her hay.

**The file names are not mandatory at the moment** 

Put your files in one directory with exactly the name specified. This is ugly.

**The files must have a header line**


### Assemblies

Filename: `transcript_assemblies.csv`

Example: 

    name,prefix,add_prefix,description,program,parameters,assembly_date,path,is_primary
    rose_v1,rose_v1,1,beautiful rose RNA assembled with Trinity,Trinity 20140413p1,--seqType fq --JM 40G --left ${base}_1.fastq  --right ${base}_2.fastq --CPU 12 --normalize_reads --trimmomatic --jaccard_clip --output $projdir/data/$base/,2014-05-20,/big/data/heap/rose_transcripts.fasta,1

In that case we have one assembly of rose RNA which we call `rose_v1`. Since
you are lazy, you just left the Trinity assembly as it is and the transcripts
have ids like `>c99_g1_i17`. This is nice, but not when you want to compare it
to another Trinity assembly! So TearDrop can add a `prefix` for you
(`add_prefix`=1) or not (`add_prefix=0`). `is_primary` is informational at this
point and points to your favorite special assembly (not that you don't love the
others as well, of course).

### Organisms

Filename: `organisms.csv`

Example:

   name,scientific_name,genome_version,genome_path
   rose,Rosa Rosalis rosorum SPP 11,RRR11,/big/data/heap/rosa_RRR11.fasta

The `genome_path` is purely informational. It's helpful if it points to the
genome you align against! Make sure that the chromosome names in there are
different from those in the annotation files, this is all the rage nowadays
(yes, I'm looking at you, WS and TAIR people!)

### Alignments

Filename: `alignments.csv`

Example:

    type,assembly,program,sample_id,bam_path,parameters,use_original_id
    genome,rose,star,crazy_rep1,/big/data/heap/genomic_crazy_rep1.bam,,
    transcriptome,rose_v1,bowtie2,crazy_rep1,/big/data/heap/transcriptomic_crazy_rep1.bam,bowtie2 --sensitive -a --mm -p 8 -x $genome -1 $fq1 -2 $fq2 2>bowtie_stats.txt | samtools view -Sbu - | samtools sort -m 1000000000 - $samout,1

The `type` field tells us whether you aligned to a genome or the transcripts.
`assembly` refers to the `organism` in the case of genomic alignments,
otherwise to the transcript assembly. `use_original_id` should be `1` if the
transcripts were prefixed by TearDrop during import.

# MORE TO COME

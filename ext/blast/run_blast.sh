#!/bin/bash

db_path=$1
shift

query=$1
shift

if [ -z "$db_path" -o -z "$query" ]; then
  echo "Usage $0 [db_path] [query]"
fi

/usr/local/ncbi/blast/bin/blastx -db $db_path \
  -num_threads 4 \
  -evalue .01 \
  -max_target_seqs 20 \
  -outfmt "6 qseqid sseqid bitscore qlen length nident pident ppos evalue slen stitle" \
  -query $query

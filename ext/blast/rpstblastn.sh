#!/bin/bash

db_path=$1
shift

query=$1
shift

evalue=$1
shift

max_target_seqs=$1
shift


if [ -z "$db_path" -o -z "$query" ]; then
  echo "Usage $0 [db_path] [query]"
fi
if [ -z "$evalue" ]; then
  evalue=.01
fi
if [ -z "$max_target_seqs" ]; then
  max_target_seqs=20
fi

rpstblastn -db $db_path \
  -num_threads 4 \
  -evalue $evalue \
  -max_target_seqs $max_target_seqs \
  -outfmt "6 qseqid sseqid bitscore qlen length nident pident ppos evalue slen qseq sseq qstart qend sstart send stitle" \
  -query $query

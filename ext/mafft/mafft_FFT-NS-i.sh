#!/bin/bash

fasta=$1
shift

if [ -z "$fasta" ]; then
  echo "Usage: $0 [fasta]"
  exit -1
fi

mafft --nuc --retree 2 --maxiterate 1000 $fasta

#!/bin/bash

ref=$1
shift

contig=$1
shift

if [ -z "$ref" -o -z "$contig" ]; then
  echo "Usage: $0 [ref] [contig]"
  exit 1
fi

samtools mpileup --ff UNMAP -r $contig -f $ref $@ 

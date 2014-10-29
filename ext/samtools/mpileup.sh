#!/bin/bash

ref=$1
shift

contig=$1
shift

samtools mpileup -r $contig -f $ref $@ 

#!/bin/bash

ref=$1
shift

contig=$1
shift

samtools mpileup --ff UNMAP -r $contig -f $ref $@ 

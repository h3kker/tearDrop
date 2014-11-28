#!/bin/bash

db_path=$1
shift

entry=$1
shift


if [ -z "$db_path" ]; then
  echo "Usage $0 [db_path]"
  exit 1
fi

if [ -z "$entry" ]; then
  opt="-entry_batch -"
else
  opt='-entry '$entry
fi

blastdbcmd -db "$db_path" $opt

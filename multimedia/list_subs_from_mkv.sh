#!/usr/bin/env bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <input.mkv>" >&2
  exit 1
fi

INPUT="$1"

ffprobe -v error \
  -select_streams s \
  -show_entries stream=index:stream_tags=language,title \
  -of compact=p=0:nk=1 \
  "$INPUT"

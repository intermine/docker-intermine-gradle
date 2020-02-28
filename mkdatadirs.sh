#!/usr/bin/env sh

awk 'BEGIN {FS="\n"} {
  for (i=1; i<=NF; i++) {
    if ($i ~ /^ *volumes:/) {
      reading=1
    } else if (reading) {
      if ($i ~ /^ *-/) {
        start=index($i, "-")+2
        count=index($i, ":")-start
        print substr($i, start, count)
      } else if ($i !~ /^ *#/) {
        reading=0
      }
    }
  }
}' $1 | xargs mkdir -p

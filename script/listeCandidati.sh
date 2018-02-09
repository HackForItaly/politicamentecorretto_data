#!/bin/bash



# imposto una variabile per settare il path assoluto dello script
cartella="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p "$cartella"/../listeCandidati

rm "$cartella"/../listeCandidati/*.csv

set -x

cd "$cartella"/../listeCandidati

curl "http://dait.interno.gov.it/elezioni/trasparenza" | pup "div.table-responsive:nth-child(4) > table:nth-child(1) a[href*=csv] json{}" | jq -r '("http://dait.interno.gov.it" + .[].href)' | xargs wget

for f in *.csv; do csvformat -d ";" -e "ISO-8859-15" "$f" > UTF8_"$f" ; done

shopt -s extglob
rm "$cartella"/../listeCandidati/!(UTF*)

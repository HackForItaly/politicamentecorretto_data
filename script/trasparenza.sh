#!/bin/bash

set -x

# imposto una variabile per settare il path assoluto dello script
cartella="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# una cartella pubblica di export dei dati
web="/home/ondata/domains/dev.ondata.it/public_html/projs/people/andy/unapromessa"

# scarico i dati
curl -sl "http://dait.interno.gov.it/elezioni/trasparenza" | scrape -be ".table > tbody:nth-child(2) > tr" | xml2json | jq '[.html.body.tr[] | {logo:("http://dait.interno.gov.it" + .td[0].img.src?),partito:.td[0].img.title?,programma:("http://dait.interno.gov.it" + .td[3].a[1]?.href?)}]' >"$cartella"/../elezioniTrasparenza/trasparenzaElezioni.json

cat "$cartella"/../elezioniTrasparenza/trasparenzaElezioni.json | in2csv -f json > "$cartella"/../elezioniTrasparenza/trasparenzaElezioni.csv

csvsql -I --query 'select *, ("file"||programma) as nomefile from trasparenzaElezioni' "$cartella"/../elezioniTrasparenza/trasparenzaElezioni.csv |  sed -r 's|(filehttp.*?\/Doc\/)(.*?)(\/)(.*)|\2-\4|g' > "$cartella"/../tmp/trasparenzaElezioni.csv

cat "$cartella"/../tmp/trasparenzaElezioni.csv > "$cartella"/../elezioniTrasparenza/trasparenzaElezioni.csv

cat "$cartella"/../tmp/trasparenzaElezioni.csv | csvjson | jq . > "$cartella"/../elezioniTrasparenza/trasparenzaElezioni.json

cat "$cartella"/../elezioniTrasparenza/trasparenzaElezioni.json | jq '[.[] | {partito:.partito,link:.programma,evento:"Elezioni Politiche 2018",amministrazione:"Governo Nazionale"}]' | yq . -y > "$cartella"/../elezioniTrasparenza/trasparenzaElezioni.yaml

csvformat -T "$cartella"/../tmp/trasparenzaElezioni.csv >"$cartella"/../tmp/trasparenzaElezioni_tmp.csv

# rimuovo la prima riga
sed -i 1d "$cartella"/../tmp/trasparenzaElezioni_tmp.csv

while IFS=$'\t' read -r logo partito programma nomefile; do
	curl "$programma" > "$cartella"/../elezioniTrasparenza/programmi/"$nomefile"
done <"$cartella"/../tmp/trasparenzaElezioni_tmp.csv


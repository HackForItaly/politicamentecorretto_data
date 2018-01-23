#!/bin/bash

# imposto una variabile per settare il path assoluto dello script
cartella="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# una cartella pubblica di export dei dati
web="/home/ondata/domains/dev.ondata.it/public_html/projs/people/andy/unapromessa"

set -x

<<comment1
comment1
# scarico il dataset di base di everypolitician
#curl -sL "https://cdn.rawgit.com/everypolitician/everypolitician-data/09f85d30811e3e5f7bd6227480f6dfb0b447b4f9/data/Italy/House/ep-popolo-v1.0.json" > ../data/everypoliticianItalia.json

# estraggo info di base (ID WikiDATA, URL Immagine e nome, ecc.)
#< "$cartella"/../data/everypoliticianItalia.json jq '[.persons[] | {wikidata:.identifiers[]| select(.scheme | contains("wikidata"))|.identifier,immagine:.image,nome:.name,everypolitician_legacy:.identifiers[]| select(.scheme | contains("everypolitician_legacy"))|.identifier,wikipediaIT:.links[]| select(.note | contains("Wikipedia (it)"))|.url,id:.id,idItalia:.identifiers[]| select(.scheme | contains("italian_cod"))|.identifier?}]' | tee "$cartella"/../data/everypoliticianItaliaPersons.json | in2csv -I -f json > "$cartella"/../data/everypoliticianItaliaPersons.csv



# estraggo info di base (ID WikiDATA, URL Immagine e nome, ecc.)
#< "$cartella"/../data/everypoliticianItalia.json jq '[.persons[] | {wikidata:.identifiers[]| select(.scheme | contains("wikidata"))|.identifier,immagine:.image,nome:.name,everypolitician_legacy:.identifiers[]| select(.scheme | contains("everypolitician_legacy"))|.identifier,wikipediaIT:.links[]| select(.note | contains("Wikipedia (it)"))|.url,id:.id,twitter:.contact_details[]? | select(.type | contains("twitter")) | .value}]' | in2csv -I -f json > "$cartella"/../data/everypoliticianItaliaPersonsTwitter.csv

#cat "$cartella"/../data/everypoliticianItaliaPersons.csv > "$cartella"/../tmp/everypoliticianItaliaPersons.csv

# faccio il join con la tabella che contiene i datti sugli account twitter e creo CSV che li contiene
#csvsql -I --query "select A.*,B.twitter from everypoliticianItaliaPersons AS A LEFT JOIN everypoliticianItaliaPersonsTwitter AS B on A.id=B.id" "$cartella"/../tmp/everypoliticianItaliaPersons.csv "$cartella"/../data/everypoliticianItaliaPersonsTwitter.csv > "$cartella"/../data/everypoliticianItaliaPersons.csv

#rm "$cartella"/../data/everypoliticianItaliaPersonsTwitter.csv

# estraggo il JSON con i dati twitter
#csvjson -I "$cartella"/../data/everypoliticianItaliaPersons.csv | jq . > "$cartella"/../data/everypoliticianItaliaPersons.json



# scarico i dati dall'anagrafica di una promessa http://bit.ly/2n1340b
curl -sL "https://docs.google.com/spreadsheets/d/e/2PACX-1vTquc_cJduDFPPrXtZvS22SD0L_hy5mQaaOH2__QKF4Fi8Y-QcKNN8gXVUatOr-TPuTv6gTEZ0rB0W6/pub?gid=249352183&single=true&output=csv" > "$cartella"/../data/unapromessa_raw.csv

# rimuovo le colonne che non servono
< "$cartella"/../data/unapromessa_raw.csv csvcut -c 1,2,3,4,5,6,7 > "$cartella"/../data/unapromessa_raw_clean.csv

# rimuovo le righe per cui non è associata un'immagine al candidato
< "$cartella"/../data/unapromessa_raw_clean.csv csvgrep -c "immagine"  -r "^http.*$" > "$cartella"/../data/unapromessa.csv

# converto i dati in JSON
csvjson -I "$cartella"/../data/unapromessa.csv | jq . > "$cartella"/../data/unapromessa.json

# pubblico online JSON e CSV
cat "$cartella"/../data/unapromessa.json > "$web"/unapromessa.json
cat "$cartella"/../data/unapromessa.csv > "$web"/unapromessa.csv


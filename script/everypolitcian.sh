#!/bin/bash

# scarico il dataset di base di everypolitician
curl -sL "https://cdn.rawgit.com/everypolitician/everypolitician-data/09f85d30811e3e5f7bd6227480f6dfb0b447b4f9/data/Italy/House/ep-popolo-v1.0.json" > ../data/everypoliticianItalia.json

# estraggo info di base (ID WikiDATA, URL Immagine e nome, ecc.)
< ../data/everypoliticianItalia.json jq '[.persons[] | {wikidata:.identifiers[]| select(.scheme | contains("wikidata"))|.identifier,immagine:.image,nome:.name,everypolitician_legacy:.identifiers[]| select(.scheme | contains("everypolitician_legacy"))|.identifier,wikipediaIT:.links[]| select(.note | contains("Wikipedia (it)"))|.url,id:.id}]' | tee ../data/everypoliticianItaliaPersons.json | in2csv -I -f json > ../data/everypoliticianItaliaPersons.csv


# estraggo info di base (ID WikiDATA, URL Immagine e nome, ecc.)
< ../data/everypoliticianItalia.json jq '[.persons[] | {wikidata:.identifiers[]| select(.scheme | contains("wikidata"))|.identifier,immagine:.image,nome:.name,everypolitician_legacy:.identifiers[]| select(.scheme | contains("everypolitician_legacy"))|.identifier,wikipediaIT:.links[]| select(.note | contains("Wikipedia (it)"))|.url,id:.id,twitter:.contact_details[]? | select(.type | contains("twitter")) | .value}]' | in2csv -I -f json > ../data/everypoliticianItaliaPersonsTwitter.csv

cat ../data/everypoliticianItaliaPersons.csv > ../tmp/everypoliticianItaliaPersons.csv

csvsql -I --query "select A.*,B.twitter from everypoliticianItaliaPersons AS A LEFT JOIN everypoliticianItaliaPersonsTwitter AS B on A.id=B.id" ../tmp/everypoliticianItaliaPersons.csv ../data/everypoliticianItaliaPersonsTwitter.csv > ../data/everypoliticianItaliaPersons.csv

rm ../data/everypoliticianItaliaPersonsTwitter.csv

csvjson -I ../data/everypoliticianItaliaPersons.csv | jq . > ../data/everypoliticianItaliaPersons.json
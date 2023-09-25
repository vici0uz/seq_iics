# IICS GET CONCENSUS PIPELINE
Put barcode data on data/input

Run pipeline via [nextflow](https://www.nextflow.io/). Notes on building and pushing Docker image are [here](https://hub.docker.com/layers/vici0uz/iics/latest/images/sha256-1c11f1fa0b9a1d3f5cb9a7f7e9e6eb97dfc23b00ea3b3fd3e44ff6bd00c8b068?context=repo)

## REQUIREMENTS
- nextflow
- docker


## SETUP
```
git clone 'https://github.com/vici0uz/seq_iics'
cd seq_iics
nextflow run main.nf --data {myDataDir} --with-docker vici0uz/iics:latest
```


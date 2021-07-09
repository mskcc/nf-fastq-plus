# Scripts
Stand-alone scripts that call the template files

## Fingerprinting
To run fingerprinting individually for requests, run the `fingerprint_projects.sh` script like below
```
# Will create directories named after each project that will run the crosscheck nextflow script
PROJECTS="05469_BQ  12177_B  12189"
./fingerprint_projects.sh ${PROJECTS}
```

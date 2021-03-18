# IGO Data Team App Template

## Send nextflow events
```
nextflow /PATH/TO/nf-fastq-plus/main.nf --run <RUN_NAME> -with-weblog http://lski2780:3221/api/nextflow/send-nextflow-event
```

## Dependencies
- mongo

## QuickStart
### I) Frontend 
```
$ cd ./template-frontend-react && npm install && npm run start # cd ./template-frontend-vue
```
### II) Mongo
```
$ mongod
```
### III) Backend
```
$ cd ./template-backend && npm install && npm run dev
```

# IGO Data Team App Template

## Send nextflow events
LOCAL
```
nextflow /PATH/TO/nf-fastq-plus/main.nf --run <RUN_NAME> -with-weblog http://lski2780:3221/api/nextflow/send-nextflow-event
```

VMs

* On the VMs, I'm not able to send via https, so add the host & port the app is served from
```
... -with-weblog "http://dlviigoweb1:4500/api/nextflow/send-nextflow-event" -bg
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

## Deployment
Deploy scripts will create a directory that can be deployed and served w/ `npm run start`
### QA
``` 
make ENV=qa HOST=dlviigoweb1 deploy
```

### PROD
``` 
make ENV=prod HOST=plviigoweb1 deploy
```

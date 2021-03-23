# NF-FASTQ-PLUS DASHBOARD

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
$ cd ./frontend && npm install && npm run start     # Should now be running on localhost:3000
```
### II) Mongo
```
$ mongod
```
### III) Backend
```
$ cd ./api && npm install && npm run dev            # Should now be running on localhost:4500
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

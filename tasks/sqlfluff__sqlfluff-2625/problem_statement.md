Suppress dbt logs and warnings when using --format github-annotation
Sometimes, running:
```
sqlfluff lint --format github-annotation --annotation-level failure --nofail 
```

Can result in the first couple of output lines being logs which break the annotations, for example:
```
14:21:42  Partial parse save file not found. Starting full parse.
Warning:  [WARNING]: Did not find matching node for patch with name 'xxxx' in the 'models' section of file 'models/production/xxxxx/xxxxx.yml'
```

## Version
dbt 1.0.0, SQLFLuff 0.9.0


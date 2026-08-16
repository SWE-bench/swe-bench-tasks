
This sounds more like a templater feature than a dialect feature. Does psql allow variables to contain SQL fragments, e.g.: `WHERE foo = '3'`?
> This sounds more like a templater feature than a dialect feature.

True!  After looking over the code some, that may well be the right place to implement this.

> Does psql allow variables to contain SQL fragments, e.g.: WHERE foo = '3'?

Yes.  E.g.,

```
% psql -v expression='2 + 2'
psql (14.2, server 10.18)
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.

db=> select :expression;
 ?column?
----------
        4
(1 row)

db=> select 5:expression;
 ?column?
----------
       54
(1 row)
```

More at the [docs](https://www.postgresql.org/docs/current/app-psql.html#APP-PSQL-VARIABLES).
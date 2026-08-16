Configuration from current working path not being loaded when path provided.
I have the following directory structure.
```
~/GitHub/sqlfluff-bug
➜  tree -a
.
├── .sqlfluffignore
├── ignore_me_1.sql
├── path_a
│   └── ignore_me_2.sql
└── path_b
    ├── ignore_me_3.sql
    └── lint_me_1.sql

2 directories, 5 files
```
And the following ignore file

```
~/GitHub/sqlfluff-bug
➜  cat .sqlfluffignore

~/GitHub/sqlfluff-bug
➜  cat .sqlfluffignore
ignore_me_1.sql
path_a/
path_b/ignore_me_3.sql%
```

When I run the following I get the expected result. Sqlfluff only lints the one file that is not ignored.
```
~/GitHub/sqlfluff-bug
➜  sqlfluff lint .

~/GitHub/sqlfluff-bug
➜  sqlfluff lint .
== [path_b/lint_me_1.sql] FAIL
L:   2 | P:   1 | L003 | Indent expected and not found compared to line #1
L:   2 | P:  10 | L010 | Inconsistent capitalisation of keywords.
```

However when I run the lint explicitly on one of the two directories then ignored files are also linted.

```
~/GitHub/sqlfluff-bug
➜  sqlfluff lint path_a

~/GitHub/sqlfluff-bug
➜  sqlfluff lint path_a
== [path_a/ignore_me_2.sql] FAIL
L:   2 | P:   1 | L003 | Indent expected and not found compared to line #1
L:   2 | P:  10 | L010 | Inconsistent capitalisation of keywords.

~/GitHub/sqlfluff-bug
➜  sqlfluff lint path_b

~/GitHub/sqlfluff-bug
➜  sqlfluff lint path_b
== [path_b/ignore_me_3.sql] FAIL
L:   2 | P:   1 | L003 | Indent expected and not found compared to line #1
L:   2 | P:  10 | L010 | Inconsistent capitalisation of keywords.
== [path_b/lint_me_1.sql] FAIL
L:   2 | P:   1 | L003 | Indent expected and not found compared to line #1
L:   2 | P:  10 | L010 | Inconsistent capitalisation of keywords.
```

If this is the expected behaviour then it might be worthwhile to add an example to the [docs](https://docs.sqlfluff.com/en/latest/configuration.html#sqlfluffignore).

Edit: I've replicated this issue on sqlfluff version 0.3.2 to 0.3.6.

Misleading path does not exist message
It looks like if _at least one_ of the paths provided to sqlfluff do not exist, it will display an error message implying that _all_ of the supplied paths do not exist:

```bash
dbt@b54bee9ced88:/workspaces/dbt-dutchie$ sqlfluff fix models/shared/dispensaries.sql models/shares/dispensary_chains.sql
==== finding fixable violations ====
=== [dbt templater] Compiling dbt project...
== [models/shared/dispensaries.sql] FAIL
L:   6 | P:   2 | L003 | Indentation not consistent with line #376
L:   8 | P:   2 | L003 | Indentation not consistent with line #376
L:   9 | P:   3 | L003 | Line over-indented compared to line #376
L:  10 | P:   2 | L003 | Indentation not consistent with line #376
L:  12 | P:   2 | L003 | Indentation not consistent with line #376
L:  13 | P:   3 | L003 | Line over-indented compared to line #376
L:  14 | P:   4 | L003 | Line over-indented compared to line #376
L:  15 | P:   4 | L003 | Line over-indented compared to line #376
L:  16 | P:   4 | L003 | Line over-indented compared to line #376
L:  17 | P:   4 | L003 | Line over-indented compared to line #376
L:  18 | P:   4 | L003 | Line over-indented compared to line #376
L:  19 | P:   4 | L003 | Line over-indented compared to line #376
L:  20 | P:   4 | L003 | Line over-indented compared to line #376
L:  21 | P:   4 | L003 | Line over-indented compared to line #376
L:  22 | P:   4 | L003 | Line over-indented compared to line #376
L:  23 | P:   4 | L003 | Line over-indented compared to line #376
L:  24 | P:   4 | L003 | Line over-indented compared to line #376
L:  25 | P:   4 | L003 | Line over-indented compared to line #376
L:  26 | P:   4 | L003 | Line over-indented compared to line #376
L:  27 | P:   4 | L003 | Line over-indented compared to line #376
L:  28 | P:   4 | L003 | Line over-indented compared to line #376
L:  29 | P:   4 | L003 | Line over-indented compared to line #376
L:  30 | P:   4 | L003 | Line over-indented compared to line #376
L:  31 | P:   4 | L003 | Line over-indented compared to line #376
L:  32 | P:   4 | L003 | Line over-indented compared to line #376
L:  33 | P:   4 | L003 | Line over-indented compared to line #376
L:  34 | P:   4 | L003 | Line over-indented compared to line #376
L:  58 | P:   1 | L004 | Incorrect indentation type found in file.
L:  35 | P:   4 | L003 | Line over-indented compared to line #376
L:  36 | P:   4 | L003 | Line over-indented compared to line #376
L:  37 | P:   4 | L003 | Line over-indented compared to line #376
L:  38 | P:   4 | L003 | Line over-indented compared to line #376
L:  39 | P:   4 | L003 | Line over-indented compared to line #376
L:  40 | P:   4 | L003 | Line over-indented compared to line #376
L:  41 | P:   4 | L003 | Line over-indented compared to line #376
L:  42 | P:   4 | L003 | Line over-indented compared to line #376
L:  43 | P:   4 | L003 | Line over-indented compared to line #376
L:  44 | P:   4 | L003 | Line over-indented compared to line #376
L:  45 | P:   4 | L003 | Line over-indented compared to line #376
L:  46 | P:   4 | L003 | Line over-indented compared to line #376
L:  47 | P:   4 | L003 | Line over-indented compared to line #376
L:  48 | P:   4 | L003 | Line over-indented compared to line #376
L:  49 | P:   4 | L003 | Line over-indented compared to line #376
L:  50 | P:   4 | L003 | Line over-indented compared to line #376
L:  51 | P:   4 | L003 | Line over-indented compared to line #376
L:  52 | P:   4 | L003 | Line over-indented compared to line #376
L:  53 | P:   4 | L003 | Line over-indented compared to line #376
L:  54 | P:   4 | L003 | Line over-indented compared to line #376
L:  55 | P:   4 | L003 | Line over-indented compared to line #376
L:  56 | P:   4 | L003 | Line over-indented compared to line #376
L:  57 | P:   4 | L003 | Line over-indented compared to line #376
L:  58 | P:   4 | L003 | Line over-indented compared to line #376
L:  59 | P:   4 | L003 | Line over-indented compared to line #376
L:  60 | P:   4 | L003 | Line over-indented compared to line #376
L:  61 | P:   4 | L003 | Line over-indented compared to line #376
L:  62 | P:   4 | L003 | Line over-indented compared to line #376
L:  63 | P:   4 | L003 | Line over-indented compared to line #376
L:  64 | P:   4 | L003 | Line over-indented compared to line #376
L:  65 | P:   4 | L003 | Line over-indented compared to line #376
L:  66 | P:   4 | L003 | Line over-indented compared to line #376
L:  67 | P:   4 | L003 | Line over-indented compared to line #376
L:  68 | P:   4 | L003 | Line over-indented compared to line #376
L:  69 | P:   4 | L003 | Line over-indented compared to line #376
L:  70 | P:   4 | L003 | Line over-indented compared to line #376
L:  71 | P:   4 | L003 | Line over-indented compared to line #376
L:  72 | P:   4 | L003 | Line over-indented compared to line #376
L:  73 | P:   4 | L003 | Line over-indented compared to line #376
L:  74 | P:   4 | L003 | Line over-indented compared to line #376
L:  75 | P:   4 | L003 | Line over-indented compared to line #376
L:  76 | P:   4 | L003 | Line over-indented compared to line #376
L:  77 | P:   4 | L003 | Line over-indented compared to line #376
L:  78 | P:   4 | L003 | Line over-indented compared to line #376
L:  79 | P:   4 | L003 | Line over-indented compared to line #376
L:  80 | P:   4 | L003 | Line over-indented compared to line #376
L:  81 | P:   4 | L003 | Line over-indented compared to line #376
L:  82 | P:   4 | L003 | Line over-indented compared to line #376
L:  83 | P:   4 | L003 | Line over-indented compared to line #376
L:  84 | P:   4 | L003 | Line over-indented compared to line #376
L:  85 | P:   4 | L003 | Line over-indented compared to line #376
L:  86 | P:   4 | L003 | Line over-indented compared to line #376
L:  87 | P:   4 | L003 | Line over-indented compared to line #376
L:  88 | P:   4 | L003 | Line over-indented compared to line #376
L:  89 | P:   4 | L003 | Line over-indented compared to line #376
L:  90 | P:   4 | L003 | Line over-indented compared to line #376
L:  91 | P:   4 | L003 | Line over-indented compared to line #376
L:  92 | P:   4 | L003 | Line over-indented compared to line #376
L:  92 | P:  44 | L001 | Unnecessary trailing whitespace.
L:  93 | P:   4 | L003 | Line over-indented compared to line #376
L:  94 | P:   4 | L003 | Line over-indented compared to line #376
L:  95 | P:   4 | L003 | Line over-indented compared to line #376
L:  96 | P:   4 | L003 | Line over-indented compared to line #376
L:  97 | P:   4 | L003 | Line over-indented compared to line #376
L:  98 | P:   4 | L003 | Line over-indented compared to line #376
L:  99 | P:   4 | L003 | Line over-indented compared to line #376
L: 100 | P:   4 | L003 | Line over-indented compared to line #376
L: 101 | P:   4 | L003 | Line over-indented compared to line #376
L: 102 | P:   4 | L003 | Line over-indented compared to line #376
L: 103 | P:   4 | L003 | Line over-indented compared to line #376
L: 104 | P:   4 | L003 | Line over-indented compared to line #376
L: 105 | P:   4 | L003 | Line over-indented compared to line #376
L: 106 | P:   4 | L003 | Line over-indented compared to line #376
L: 107 | P:   4 | L003 | Line over-indented compared to line #376
L: 108 | P:   4 | L003 | Line over-indented compared to line #376
L: 109 | P:   4 | L003 | Line over-indented compared to line #376
L: 110 | P:   4 | L003 | Line over-indented compared to line #376
L: 111 | P:   4 | L003 | Line over-indented compared to line #376
L: 112 | P:   4 | L003 | Line over-indented compared to line #376
L: 113 | P:   4 | L003 | Line over-indented compared to line #376
L: 114 | P:   4 | L003 | Line over-indented compared to line #376
L: 115 | P:   4 | L003 | Line over-indented compared to line #376
L: 116 | P:   3 | L003 | Line over-indented compared to line #376
L: 235 | P:   1 | L004 | Incorrect indentation type found in file.
L: 117 | P:   4 | L003 | Line over-indented compared to line #376
L: 118 | P:   3 | L003 | Line over-indented compared to line #376
L: 119 | P:   4 | L003 | Line over-indented compared to line #376
L: 120 | P:   1 | L004 | Incorrect indentation type found in file.
L: 121 | P:   1 | L004 | Incorrect indentation type found in file.
L: 122 | P:   2 | L003 | Indentation not consistent with line #376
L: 339 | P:   1 | L004 | Incorrect indentation type found in file.
L: 343 | P:   1 | L004 | Incorrect indentation type found in file.
L: 347 | P:   1 | L004 | Incorrect indentation type found in file.
L: 351 | P:   1 | L004 | Incorrect indentation type found in file.
L: 355 | P:   1 | L004 | Incorrect indentation type found in file.
L: 358 | P:   1 | L004 | Incorrect indentation type found in file.
L: 361 | P:   1 | L004 | Incorrect indentation type found in file.
L: 364 | P:   1 | L004 | Incorrect indentation type found in file.
L: 367 | P:   1 | L004 | Incorrect indentation type found in file.
L: 370 | P:   1 | L004 | Incorrect indentation type found in file.
The path(s) ('models/shared/dispensaries.sql', 'models/shares/dispensary_chains.sql') could not be accessed. Check it/they exist(s).
```

## Expected Behaviour
I would expect only the unaccessible paths to be included in the error message.

## Observed Behaviour
See above

## Version
```bash
dbt@b54bee9ced88:/workspaces/dbt-dutchie$ sqlfluff --version
sqlfluff, version 0.5.2
```

```bash
dbt@b54bee9ced88:/workspaces/dbt-dutchie$ python --version
Python 3.8.6
```

## Configuration
```
[sqlfluff]
dialect = snowflake
templater = dbt
rules = L001,L002,L003,L004,L005,L006
ignore = parsing,templating

[sqlfluff:rules]
max_line_length = 120
comma_style = trailing

[sqlfluff:rules:L010]
capitalisation_policy = upper
```


Commented dash character converted to non utf-8 character
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

Upon fixing a query containing a multi-line comment, SQLFluff attempts to fix a commented line.

This:
```sql
/*
TODO
 - tariff scenario —> dm_tariff_scenario
*/
```

Became:
```sql
/*
TODO
 - tariff scenario > dm_tariff_scenario
*/
``` 
This in an invisible char represented as `<97>`

This causes an issue with dbt which can not compile with this char present

Note this comment comes at the end of the file.

### Expected Behaviour

Does not replace/fix anything that is commented

### Observed Behaviour

```bash
 $  sqlfluff fix dbt/models/marts/core/f_utility_statements.sql                                                                                                                                                                                               
==== finding fixable violations ====                                                                                                                                                                                                                          
=== [dbt templater] Sorting Nodes...                                                                                                                                                                                                                          
=== [dbt templater] Compiling dbt project...                                                                                                                                                                                                                  
=== [dbt templater] Project Compiled.                                                                                                                                                                                                                         
== [dbt/models/marts/core/f_utility_statements.sql] FAIL                                                                                                                                                                                                      
L:   1 | P:   5 | L001 | Unnecessary trailing whitespace.                                                                                                                                                                                                     
L:   2 | P:   5 | L003 | Expected 0 indentations, found 1 [compared to line 01]                                                                                                                                                                               
L:   3 | P:   9 | L003 | Expected 0 indentations, found 2 [compared to line 01]                                                                                                                                                                               
L:   4 | P:   5 | L003 | Expected 0 indentations, found 1 [compared to line 01]                                                                                                                                                                               
L:   4 | P:   6 | L019 | Found trailing comma. Expected only leading.                                                                                                                                                                                         
L:   6 | P:   5 | L003 | Expected 0 indentations, found 1 [compared to line 01]                                                                                                                                                                               
L:   7 | P:   9 | L003 | Expected 0 indentations, found 2 [compared to line 01]                                                                                                                                                                               
L:   8 | P:   5 | L003 | Expected 0 indentations, found 1 [compared to line 01]                                                                                                                                                                               
L:   8 | P:   6 | L019 | Found trailing comma. Expected only leading.                                                                                                                                                                                         
L:  10 | P:   5 | L003 | Expected 0 indentations, found 1 [compared to line 01]                                                                                                                                                                               
L:  11 | P:   9 | L003 | Expected 0 indentations, found 2 [compared to line 01]                                                                                                                                                                               
L:  12 | P:   5 | L003 | Expected 0 indentations, found 1 [compared to line 01]                                                                                                                                                                               
L:  12 | P:   6 | L019 | Found trailing comma. Expected only leading.                                                                                                                                                                                         
L:  15 | P:   5 | L003 | Expected 0 indentations, found 1 [compared to line 01]   
L:  16 | P:   9 | L003 | Expected 0 indentations, found 2 [compared to line 01]                                                                                                                                                                      [0/47960]
L:  17 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  18 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  19 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  20 | P:   9 | L003 | Expected 0 indentations, found 2 [compared to line 01]
L:  20 | P:  36 | L031 | Avoid aliases in from clauses and join conditions.
L:  21 | P:   9 | L003 | Expected 0 indentations, found 2 [compared to line 01]
L:  21 | P:  32 | L031 | Avoid aliases in from clauses and join conditions.
L:  22 | P:   5 | L003 | Expected 0 indentations, found 1 [compared to line 01]
L:  22 | P:   6 | L019 | Found trailing comma. Expected only leading.
L:  24 | P:   5 | L003 | Expected 0 indentations, found 1 [compared to line 01]
L:  26 | P:   9 | L003 | Expected 0 indentations, found 2 [compared to line 01]
L:  26 | P:  15 | L001 | Unnecessary trailing whitespace.
L:  27 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  28 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  29 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  30 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  31 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  32 | P:   9 | L003 | Expected 0 indentations, found 2 [compared to line 01]
L:  32 | P:  24 | L011 | Implicit/explicit aliasing of table.
L:  32 | P:  24 | L031 | Avoid aliases in from clauses and join conditions.
L:  33 | P:   9 | L003 | Expected 0 indentations, found 2 [compared to line 01]
L:  33 | P:  49 | L011 | Implicit/explicit aliasing of table.
L:  33 | P:  49 | L031 | Avoid aliases in from clauses and join conditions.
L:  33 | P:  52 | L001 | Unnecessary trailing whitespace.
L:  34 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  36 | P:   9 | L003 | Expected 0 indentations, found 2 [compared to line 01]
L:  37 | P:   5 | L003 | Expected 0 indentations, found 1 [compared to line 01]
L:  37 | P:   6 | L019 | Found trailing comma. Expected only leading.
L:  39 | P:   5 | L003 | Expected 0 indentations, found 1 [compared to line 01]
L:  41 | P:   9 | L003 | Expected 0 indentations, found 2 [compared to line 01]
L:  41 | P:   9 | L034 | Select wildcards then simple targets before calculations
                       | and aggregates.
L:  43 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  46 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  47 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  48 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  51 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  52 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  53 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  54 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  57 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  58 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  61 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  62 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  64 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  65 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  68 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  69 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  70 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  71 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  73 | P:   9 | L003 | Expected 0 indentations, found 2 [compared to line 01]
L:  73 | P:  36 | L031 | Avoid aliases in from clauses and join conditions.
L:  74 | P:   9 | L003 | Expected 0 indentations, found 2 [compared to line 01]
L:  74 | P:  56 | L031 | Avoid aliases in from clauses and join conditions.
L:  75 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  76 | P:   9 | L003 | Expected 0 indentations, found 2 [compared to line 01]
L:  76 | P:  28 | L001 | Unnecessary trailing whitespace.
L:  77 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  80 | P:   9 | L003 | Expected 0 indentations, found 2 [compared to line 01]
L:  81 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  83 | P:  13 | L003 | Expected 0 indentations, found 3 [compared to line 01]
L:  84 | P:   5 | L003 | Expected 0 indentations, found 1 [compared to line 01]
L:  94 | P:   1 | L009 | Files must end with a single trailing newline.
```

### How to reproduce

`sqlfluff fix` with provided `.sqlfluff` configuration

SQL contains proprietary code and I am, likely, unable to provide a full snippet of the SQL 

### Dialect

Snowflake

### Version

0.13.0 and 0.11.1

### Configuration

`.sqlfluff`:
```
[sqlfluff]
templater = dbt
dialect = snowflake

[sqlfluff:templater:dbt]
project_dir = dbt/

# Defaults on anything not specified explicitly: https://docs.sqlfluff.com/en/stable/configuration.html#default-configuration
[sqlfluff:rules]
max_line_length = 120
comma_style = leading

# Keyword capitalisation
[sqlfluff:rules:L010]
capitalisation_policy = lower

# TODO: this supports pascal but not snake
# TODO: this inherits throwing violation on all unquoted identifiers... we can limit to aliases or column aliases
# [sqlfluff:rules:L014]
# extended_capitalisation_policy = pascal

# TODO: not 100% certain that this default is correct
# [sqlfluff:rules:L029]
## Keywords should not be used as identifiers.
# unquoted_identifiers_policy = aliases
# quoted_identifiers_policy = none
## Comma separated list of words to ignore for this rule
# ignore_words = None

# Function name capitalisation
[sqlfluff:rules:L030]
extended_capitalisation_policy = lower
```

### Are you willing to work on and submit a PR to address the issue?

- [X] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)


Write-output human format does not produce result
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

When running SQLFluff using the following statement:
`python -m sqlfluff lint --write-output test.txt --config=config/sql-lint.cfg`
no result was produced.

### Expected Behaviour

I expect a file to appear, in this case called test,txt, containing all violations found.

### Observed Behaviour

Looking through the code I saw human was the default format so expected adding --format=human would not make a difference. To be sure, I also ran the statement using the flag and it still produced nothing.

To make sure it was just the human format which was having problems, I also executed the statement using --format=json,yaml,github-annotations, all of which did produce the expected result which leads me to believe there is something wrong with the human format.

### How to reproduce

I imagine simply executing `sqlfluff lint --write-output test.txt example.sql`

### Dialect

T-SQL

### Version

0.11.2

### Configuration

[sqlfluff]
dialect = tsql
exclude_rules = L014,
                L016,
                L031,
                L035,
                L059

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)


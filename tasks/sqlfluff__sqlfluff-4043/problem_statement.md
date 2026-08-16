add ability to render the compiled sql
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### Description

It would be nice to see the compiled sql in which any templates are rendered. I would be happy to work on this but it may be a struggle and would need some guidance.

### Use case

 It would help debug linting errors around jinja templates.
It would also make it easier to copy and use the query in the bigquery ui, for example. We process our queries through Airflow so currently I can start a dag run and look at the rendered template to get this effect. That's not very efficient though :)


### Dialect

We use bigquery but this could apply to all dialects.

### Are you willing to work on and submit a PR to address the issue?

- [X] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)


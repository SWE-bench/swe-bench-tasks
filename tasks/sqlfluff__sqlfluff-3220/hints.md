I believe the fix would be to just add a `default=None,` to the @click.option decorator.
This is simple enough for me to create a PR but I don't know how to create tests (or if just adding it is enough) for it as required on the PR template.
> I believe the fix would be to just add a `default=None,` to the @click.option decorator.
Confirmed that worked

> This is simple enough for me to create a PR but I don't know how to create tests (or if just adding it is enough) for it as required on the PR template.

It would be good to have a test. If you look at `test/fixtures/linter/autofix/snowflake/001_semi_structured` you can see a similar test that uses a .sqlfluff config file for the test run.
I'm happy to take this unless you want to do it, @pekapa. I fixed a very similar issue with the `--encoding` option a few weeks ago.
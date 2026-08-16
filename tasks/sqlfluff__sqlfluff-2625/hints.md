my workaround was to add `sed -i '/^\[/!d' annotations.json` to the git actions command to delete the extra lines from dbt that were not part of the annotations beginning with `[`
Perhaps the better solution here is to add an ability for SQLFluff to write an annotations.json file itself with a command like
```
sqlfluff lint --format github-annotation --annotation-level failure --nofail ${{ steps.get_files_to_lint.outputs.lintees }} --write-output annotations.json
```
which would still allow the user to see log outputs, rather than the user having to stream the logs into a file with:

```
sqlfluff lint --format github-annotation --annotation-level failure --nofail ${{ steps.get_files_to_lint.outputs.lintees }} > annotations.json
```
Relates to https://github.com/sqlfluff/sqlfluff-github-actions/issues/15
@NiallRees: That sounds like a great suggestion -- I had the same thought. I was the original author of the `github-annotation` format, and it seemed natural to add it to the existing list of formats. TBH, of the 4 formats, only one is intended for humans. If we make this change, I suggest we consider changing all the formats to support this.
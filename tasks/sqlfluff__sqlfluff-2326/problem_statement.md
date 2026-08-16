`AnySetOf` grammar
<!--Note: This is for general enhancements to the project. Please use the Bug report template instead to raise parsing/linting/syntax issues for existing supported dialects-->
I know this has been talked about before in PRs so making an issue to formally track.

In many grammars there's a common situation where we have to denote several options that can be specified in any order but they cannot be specified more than once.

Our general approach to this in the project has been denote this using `AnyNumberOf` as this allows for the different orderings:
```python
AnyNumberOf(
    <option_1_grammar>,
    <option_2_grammar>,
    ...
)
```
However, the issue with this is that it places no limit on how many times each option can be specified.

This means that sqlfluff allows certain invalid statements to parse e.g.
```sql
CREATE TABLE ktw_account_binding (
    ktw_id VARCHAR(32) NOT NULL REFERENCES ref_table(bla)
    ON DELETE RESTRICT ON DELETE CASCADE ON DELETE CASCADE ON DELETE CASCADE
);
```
https://github.com/sqlfluff/sqlfluff/pull/2315#issuecomment-1013847846

We've accepted this limitation for the time being as it's more important to get the statements parsing for linting/formatting purposes rather than exactly reflecting the grammar (we'd expect a general degree of common sense when it comes to repeating these options).

That being said it would be nice to address this to refine our grammar and reduce dealing with contributor confusion.

`AnySetOf` would essentially allow all of it's grammar arguments to be parsed in any order a maximum of 1 time each. Hopefully we can inherit from `AnyNumberOf` to simplify this.

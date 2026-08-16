As discussed on slack:

Checking a few versions back your example has never worked.
I think the templating ignoring is pretty basic (it's not included in our documentation).

So this works:

```sql
SELECT
  {{ test }} --noqa: TMP
FROM
  table1
```

But think anything beyond that simple use case, it struggles with.

Will leave this issue open to see if it can be improved but for now the best solution is to defined that macro in the config (though I don't think dots in macros names are even supported in Jinja so not sure this is even possible?)
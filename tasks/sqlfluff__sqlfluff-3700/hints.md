Unfortunately there is not much we can do without the SQL that produces this error (ideally a minimal reproducible example SQL) so will need to close this issue if we don’t get that.
I have updated the issue with a sample query. The query is very vague but it reproduces the error. Let me know if it helps.
Looks like this simpler example also produces it:

```sql
WITH cte1 AS (
	SELECT a
	FROM (SELECT a)
)

SELECT a FROM cte1
```

This only has one linting failure:

```
$ sqlfluff lint test.sql --dialect snowflake                       
== [test.sql] FAIL                                                                                                                                                            
L:   3 | P:   7 | L042 | from_expression_element clauses should not contain
                       | subqueries. Use CTEs instead
All Finished 📜 🎉!
```

So basically L042 gets in a recursive loop when trying to fix CTEs that also break L042.

For now you can manually fix that (or exclude L042 for this query) to prevent the error.
Another good test query:
```
WITH cte1 AS (
    SELECT *
    FROM (SELECT * FROM mongo.temp)
)

SELECT * FROM cte1
```
PR #3697 avoids the looping behavior. Lint issues are still flagged, but the rule does not attempt to fix it _if_ it would cause a loop. We should still try and figure out why this is happening, so the rule can actually autofix the code, but that's lower priority (and probably a separate PR).
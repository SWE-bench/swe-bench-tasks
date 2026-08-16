Does running `sqlfluff fix` again correct the SQL?
@tunetheweb yes, yes it does. Is that something that the user is supposed to do (run it multiple times) or is this indeed a bug?
Ideally not, but there are some circumstances where it’s understandable that would happen. This however seems an easy enough example where it should not happen.
This appears to be a combination of rules L036, L003, and L039 not playing nicely together.

The original error is rule L036 and it produces this:

```sql
WITH example AS (
    SELECT
my_id,
        other_thing,
        one_more
    FROM
        my_table
)

SELECT *
FROM example
```

That is, it moves the `my_id` down to the newline but does not even try to fix the indentation.

Then we have another run through and L003 spots the lack of indentation and fixes it by adding the first set of whitespace:

```sql
WITH example AS (
    SELECT
    my_id,
        other_thing,
        one_more
    FROM
        my_table
)

SELECT *
FROM example
```

Then we have another run through and L003 spots that there still isn't enough indentation and fixes it by adding the second set of whitespace:

```sql
WITH example AS (
    SELECT
        my_id,
        other_thing,
        one_more
    FROM
        my_table
)

SELECT *
FROM example
```

At this point we're all good.

However then L039 has a look. It never expects two sets of whitespace following a new line and is specifically coded to only assume one set of spaces (which it normally would be if the other rules hadn't interfered as it would be parsed as one big space), so it think's the second set is too much indentation, so it replaces it with a single space.

Then another run and L003 and the whitespace back in so we end up with two indents, and a single space.

Luckily the fix is easier than that explanation. PR coming up...


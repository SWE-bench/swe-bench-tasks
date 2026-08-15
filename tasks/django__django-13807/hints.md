Thanks for the report, I was able to reproduce this issue with db_table = 'order'. Reproduced at 966b5b49b6521483f1c90b4499c4c80e80136de3.
Simply wrapping table_name in connection.ops.quote_name should address the issue for anyone interested in picking the issue up.
a little guidance needed as this is my first ticket.
will the issue be fixed if i just wrap %s around back ticks -> %s as in 'PRAGMA foreign_key_check(%s)' and 'PRAGMA foreign_key_list(%s)' % table_name?
Nayan, Have you seen Simon's comment? We should wrap with quote_name().
"Details: due to missing back ticks around %s in the SQL statement PRAGMA foreign_key_check(%s)" But it is quoted that this should fix the issue.
shall i wrap "table_name" in "quote_name" as in "quote_name(table_name)"?
shall i wrap "table_name" in "quote_name" as in "quote_name(table_name)"? yes, self.ops.quote_name(table_name)
First contribution, currently trying to understand the code to figure out how to write a regression test for this. Any help in how to unit test this is appreciated.
I believe I got it. Will put my test in tests/fixtures_regress which has a lot of regression tests for loaddata already, creating a new Order model and a fixture for it.
Suggested test improvements to avoid the creation of another model.
Things have been busy for me but I'm still on it, I'll do the changes to the patch later this week.
Since this issue hasn't received any activity recently, may I assign it to myself?
Sure, feel-free.
Patch awaiting review. PR: ​https://github.com/django/django/pull/13807
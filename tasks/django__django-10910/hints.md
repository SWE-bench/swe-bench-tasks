Using a timedelta as the tzinfo argument to database functions looks untested so I can understand if it's not working.
It's about tzinfo=datetime.timezone(datetime.timedelta(...)) not tzinfo=datetime.timedelta(...).
​PR
Tests aren't passing.
I needed help about sqlite3 date parse process. I've tried to solve it in _sqlite_datetime_parse func.
Oracle support is missing.
Bar the release note change, and the Oracle CI, this looks good to go.
New test fails on Oracle, so...
OK, rebased and looking good. Thanks Can!
Marking PnI since Mariusz asked for a simplification of the SQLite version. (Can, please uncheck when you've looked at that.)
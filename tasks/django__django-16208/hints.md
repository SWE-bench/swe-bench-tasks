Patch: ​https://github.com/django/django/pull/12219
Note: BEGIN is logged only on SQLite as a workaround to start a transaction explicitly in autocommit mode, you will not find it in loggers for other databases.
Author updated patch
Discussed w/ Simon while at DjangoCon US 2022 Sprints, will grab this to try to get this over the line.
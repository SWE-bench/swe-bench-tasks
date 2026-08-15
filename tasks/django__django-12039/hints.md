PR: ​https://github.com/django/django/pull/12039
OK, I'll Accept this as a clean up (there's not actually an error right?). The patch looks small/clean enough at first glance.
Correct, no error. But since it's not documented as valid syntax to not have whitespace between the column and the ordering it could break in future database versions.
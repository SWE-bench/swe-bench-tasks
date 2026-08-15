Thanks for the report. Note that everything works for BigIntegerField().
Thank you for the update. I'll switch to that for now.
Hi! I tried to tackle this issue, since it doesn't seem to complicated as a first glance :) PR: ​https://github.com/django/django/pull/13592
Add unit tests and improved the patch. Ready for another round of reviews :)
Left some comments regarding the use of related_fields_match_type in tests.
Thanks for the comment Simon! I adapted the tests, please see ​https://github.com/django/django/pull/13592#issuecomment-716212270 for more details
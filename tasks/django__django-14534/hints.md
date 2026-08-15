Hey Jacob — Sounds right: I didn't look in-depth but, if you can put your example in a test case it will be clear enough in the PR. Thanks.
Thanks Carlton, I will create a pull request asap.
Here is a pull request fixing this bug: ​https://github.com/django/django/pull/14533 (closed without merging)
Here is the new pull request ​https://github.com/django/django/pull/14534 against main
The regression test looks good; fails before fix, passes afterward. I don't think this one ​qualifies for a backport, so I'm changing it to "Ready for checkin." Do the commits need to be squashed?
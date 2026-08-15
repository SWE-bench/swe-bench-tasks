Accepted, however I don't think your patch is correct. The check should be relative to the current year, if I read the RFC quote correctly.
Created a pull request: Created a pull request: ​https://github.com/django/django/pull/9214
Still some suggested edits on the PR.
I added regression test that fails with old code (test_parsing_rfc850_year_69), updated commit message to hopefully follow the guidelines, and added additional comments about the change. Squashed commits as well. Could you review the pull request again?
sent new pull request
This is awaiting for changes from Tim's feedback on PR. (Please uncheck "Patch needs improvement" again when that's done. 🙂)
As this issue hasn't received any updates in the last 8 months, may I work on this ticket?
Go for it, I don't think I will have time to finish it.
Thanks, I'll pick up from where you left off in the PR and make the recommended changes on a new PR.
Tameesh Biswas Are you working on this ?
Yes, I am.
I've just picked up from the previous PR and opened a new PR here: ​https://github.com/django/django/pull/10749 It adds regression tests in the first commit that pass without applying the fix and adds the fix with another test-case that only passes with the fix applied. Could you please review the changes?
Tameesh, I left a comment on the PR regarding the use of non-UTC today.
As an issue haven't received an update for 4 months, I'm taking it over (djangocon europe 2019 sprint day 1).
Created new PR: ​https://github.com/django/django/pull/11212
I think an earlier comment by Simon Charette (about using a fixed year in the tests) still applies to the new PR; I've added it.
Taking the liberty to reassign due to inactivity (6 months) and adding a pull request with revised code and addressing feedback on prior PRs. Please add give your comments for any concerns:) PR => ​https://github.com/django/django/pull/11848 Year is now checked in relation to current year, rolling over to the past if more than 50 years in the future Test now uses a patched version of datetime.datetime to pin to a specific year and have static test cases, addressing feedback from charettes@ on PR 10749 in Dec 2018.
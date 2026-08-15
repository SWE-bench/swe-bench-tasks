Labeling this as a good first issue as this is a straight forward change that should not bring up any API design issues (yes technically changing the wording of an error message may break someone, but that is so brittle I am not going to worry about that).  Will need a test (the new line example is a good one!).
@e5f6bd If you are interested in opening a PR with this change, please have at it!
@e5f6bd Thanks, but I'm a bit busy recently, so I'll leave this chance to someone else.
If this issue has not been resolved yet and nobody working on it  I would like to try it
Looks like #21968 is addressing this issue 
yeah but the issue still open 
Working on this now in axes_.py,
future plans to work on this in _all_ files with error raising.
Also converting f strings to template strings where I see them in raised errors
> Also converting f strings to template strings where I see them in raised errors

f-string are usually preferred due to speed issues. Which is not critical, but if one can choose, f-strings are not worse.
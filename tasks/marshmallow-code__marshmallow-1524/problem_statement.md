Incorrect Email Validation
https://github.com/marshmallow-code/marshmallow/blob/fbe22eb47db5df64b2c4133f9a5cb6c6920e8dd2/src/marshmallow/validate.py#L136-L151

The email validation regex will match `email@domain.com\n`, `email\n@domain.com`, and `email\n@domain.com\n`.

The issue is that `$` is used to match until the end of a string. Instead, `\Z` should be used. - https://stackoverflow.com/a/48730645

It is possible that other validators might suffer from the same bug, so it would be good if other regexes were also checked.

It is unclear, but this may lead to a security vulnerability in some projects that use marshmallow (depending on how the validator is used), so a quick fix here might be helpful. In my quick look around I didn't notice anything critical, however, so I figured it would be fine to open this issue.

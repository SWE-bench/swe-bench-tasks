Thanks for the report Keryn. This looks reasonable.
happy to look into this.
I ran into this recently and ended up diagnosing the failure so I really hope you do not mind me jumping in and offering a PR Jeff. The path parameter regex was just a bit too strict about parsing spaces, and so ended up ignoring the pattern entirely PR: ​https://github.com/django/django/pull/10336 I believe this fixes the issue but I'm not sure how much we want to document this. Should we raise a check failure?
I think it would be be best to prohibit whitespace.
I agree, prohibiting whitespace would be best, it would avoid 'dialects' of urlconfs appearing and the potential for future problems.
Tim, Adam, So do we want to raise ImproperlyConfigured when whitespace is used ?
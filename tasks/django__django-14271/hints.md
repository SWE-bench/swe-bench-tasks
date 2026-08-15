It seems to be related to https://code.djangoproject.com/ticket/32143 (​https://github.com/django/django/commit/8593e162c9cb63a6c0b06daf045bc1c21eb4d7c1)
Looks like the code doesn't properly handle nested subquery exclusion, likely due to re-aliasing in Query.trim_start.
After ​a bit of investigation it seems the issue might actually lies in sql.Query.combine possibly with how it doesn't handle external_aliases.
It ended up being an issue in Query.combine when dealing with subq_aliases.
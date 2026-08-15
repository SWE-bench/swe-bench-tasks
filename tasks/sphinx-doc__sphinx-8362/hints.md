`ClassDocumenter` doesn't seem to set `follow_wrapped` to `True` when extracting a signature.

https://github.com/sphinx-doc/sphinx/blob/38b868cc0d0583d9a58496cd121f0bc345bf9eaa/sphinx/ext/autodoc/__init__.py#L1401
The same thing occurs here:

https://github.com/sphinx-doc/sphinx/blob/38b868cc0d0583d9a58496cd121f0bc345bf9eaa/sphinx/ext/autodoc/type_comment.py#L120-L122

This causes `type_sig` and `sig` to have different parameters and throw `KeyError` here:

https://github.com/sphinx-doc/sphinx/blob/38b868cc0d0583d9a58496cd121f0bc345bf9eaa/sphinx/ext/autodoc/type_comment.py#L125
@tk0miya Correct me if I'm wrong. It looks like just specifying `follow_wrapped=True` solves the issue. If so, I'd be happy to open a PR (that makes the change and adds some tests to verify it).
@harupy You're right! Could you make a PR, please? Additionally, cases of `__call__` and `__new__` are also needed to add `follow_wrapped=True`, I think. Could you check them too if possible?
@tk0miya Created a PR: https://github.com/sphinx-doc/sphinx/pull/8115 😄 
This issue prevents me from upgrading from 3.0 to 3.2.1, the bugfix by @harupy works perfectly.
@tk0miya Could you review #8115?
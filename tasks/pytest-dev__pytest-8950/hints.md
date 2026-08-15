lovely find, should do
Agreed. Also should not affect many users as I suspect almost everyone just writes `pytest.skip("some message")` rather than `pytest.skip(msg="some message")`, so they shouldn't be affected.
👍 agree to unify, would like to tackle it if you don't mind @The-Compiler ? I assume _some_ people will be using `keyword` args here, so do we deprecate over 2 releases? (any guidance on the deprecation approach would be useful)

edit: I see, it's on the explicit `pytest.skip()` calls, so much less audience as well.

Do we care about also having `def fail(reason=...`) as well?
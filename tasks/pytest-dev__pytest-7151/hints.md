Here's a unit test to add to https://github.com/pytest-dev/pytest/blob/master/testing/test_unittest.py when the fix is ready. (Passes on ``5.3.5``, Fails on ``5.4.0``)
```python
def test_outcome_errors(testdir):
    testpath = testdir.makepyfile(
        """
        import unittest
        class MyTestCase(unittest.TestCase):
            def test_fail(self):
                raise Exception("FAIL!")
            def tearDown(self):
                print(self._outcome.errors)
    """
    )
    reprec = testdir.inline_run(testpath)
    passed, skipped, failed = reprec.countoutcomes()
    assert failed == 1, failed
```
If pytest does TDD, I can just create a pull-request for this test right now if you want, and it'll be failing until the issue is fixed.
@mdmintz are you sure your test is related to this issue? See https://github.com/pytest-dev/pytest/pull/7049#issuecomment-611399172.

If not, could you please open a separate issue? Thanks!
@nicoddemus I created #7000 for it, but @blueyed closed that as a duplicate, and it might not be a duplicate, but it is related to unittest tearDown, as the outcome._errors value is missing there. Also see @blueyed's comment here: https://github.com/seleniumbase/SeleniumBase/issues/534#issuecomment-607570211 
When #7000 is fixed, that test will pass.
@mdmintz 
Yes, it is the same root cause, just another symptom (https://github.com/pytest-dev/pytest/issues/7000#issuecomment-607749633).
Can I work on this?
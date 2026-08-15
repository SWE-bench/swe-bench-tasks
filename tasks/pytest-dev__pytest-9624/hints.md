pytest generally requires that test classes can be instantiated without arguments e.g. `TestClass()`. Can you explain what the `test_method` stuff does?
@bluetech I haven't realized that `test_method` is something coming from my own code! This error appeared right after pytest 7.0.0 was released, in previous versions nothing was printed. (Yes, we don't pin version of pytest.)

The code I have is written for Python's `unittest` module. I am using pytest as a runner for its junit.xml generation feature. All tests have this as their superclass

```python
class TestCase(unittest.TestCase, Tester):  # pylint: disable=too-many-public-methods
    """A TestCase that sets up its own working directory and is also a Tester."""

    def __init__(self, test_method):
        unittest.TestCase.__init__(self, test_method)
        Tester.__init__(self, self.id())
```

(https://github.com/skupperproject/skupper-router/blob/54cd50fd59cd20f05dfb0987a72ce7f8333e07ed/tests/system_test.py#L819-L824)

I'll try to understand what this is actually doing and I'll get back to you.

I am leaving it up to you whether you want to treat this as regression (pytest used to run fine before) or whether you decide we are doing something silly which pytest won't support.

Seems to me this is just trying to 'properly' call the superclass constructor in the derived class constructor. Good OOP! There does not seem to be no magic or meaning in it.
Are you able to add a default value for `test_method`, like `unittest.TestCase` does?

https://github.com/python/cpython/blob/fea7290a0ecee09bbce571d4d10f5881b7ea3485/Lib/unittest/case.py#L374

Regardless, I would like to understand why this started happening in pytest 7.0, as it might indicate some problem. So if are able to reduce the issue a bit more, that'd be great. From the stacktrace it looks like it's happening in a failure case where a test's setup or teardown raise.
@bluetech looking at the trace back, i suspect there is a potential issue stemming from the instance node removal (as the traceback inidcates the attempt to create a new unittest testcase instance in traceback cutting, i believe thats not the intent,

 
@bluetech there is a disparity in how we get the objects for testcase objects and for normal python tests

the normal case in testcase intentionally passes name, the traceback cutting case will however occasionally trigger making a new instance without adding the object

i wonder how how to best make this fit/change

a quickfix is likely going to need a test for unittest Testcase objects and a own _get_obj implementation 
@bluetech I certainly can add the default value. Thankfully it is all my code. I'll probably do that, because 1) it is proper OOP and 2) it workarounds this problem.

## Reproducer

```python
import unittest


class Tester:

    def __init__(self, id):
        self.cleanup_list = []


class TestCase(unittest.TestCase, Tester):

    def __init__(self, test_method):
        unittest.TestCase.__init__(self, test_method)
        Tester.__init__(self, self.id())


class StreamingMessageTest(TestCase):

    @classmethod
    def setUpClass(cls):
        super(StreamingMessageTest, cls).setUpClass()

    @classmethod
    def tearDownClass(cls) -> None:
        assert False

    def test_11_streaming_closest_parallel(self):
        pass


if __name__ == '__main__':
    unittest.main()
```

This shows the previously described error with pytest==7.0.0 but prints a correct testlog and the stacktrace for the failing assert with pytest==6.2.5.

I saved the above to file called scratch_1.py and run it with

```
venv/bin/python -m pytest -vs --pyargs scratch_1
```
Thanks @jiridanek, I will try to check it out soon. It's probably as @RonnyPfannschmidt says due to the `Instance` collector removal, and it shouldn't be hard to make it work again.
> It's probably as @RonnyPfannschmidt says due to the `Instance` collector removal, and it shouldn't be hard to make it work again.

Correct - bisected to 062d91ab474881b58ae1ff49b4844402677faf45 ("python: remove the `Instance` collector node", #9277).
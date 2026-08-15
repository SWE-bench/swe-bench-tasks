Thanks for the fantastic report @linw1995, this is really helpful :smile: 
I find out the purpose of replacing '.[' with '['. The older version of pytest, support to generate test by using the generator function.

[https://github.com/pytest-dev/pytest/blob/9eb1d55380ae7c25ffc600b65e348dca85f99221/py/test/testing/test_collect.py#L137-L153](https://github.com/pytest-dev/pytest/blob/9eb1d55380ae7c25ffc600b65e348dca85f99221/py/test/testing/test_collect.py#L137-L153)

[https://github.com/pytest-dev/pytest/blob/9eb1d55380ae7c25ffc600b65e348dca85f99221/py/test/pycollect.py#L263-L276](https://github.com/pytest-dev/pytest/blob/9eb1d55380ae7c25ffc600b65e348dca85f99221/py/test/pycollect.py#L263-L276)

the name of the generated test case function is `'[0]'`. And its parent is `'test_gen'`. The line of code `return s.replace('.[', '[')` avoids its `modpath` becoming `test_gen.[0]`. Since the yield tests were removed in pytest 4.0, this line of code can be replaced with `return s` safely.


@linw1995 
Great find and investigation.
Do you want to create a PR for it?
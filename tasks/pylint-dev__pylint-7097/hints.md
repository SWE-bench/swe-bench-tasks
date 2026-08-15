@jwilk thanks for the report.
This bug is triggered in the `imp` module that `astroid` uses.
To be honest i don't think it worth developing a fix inside `astroid` to solve this kind of issue that is rare and quite easy to avoid.
@AWhetter @Pierre-Sassoulas @PCManticore what do you think about it?
This is strange, we have a functional test with a bogus encoding already (https://github.com/PyCQA/pylint/blob/master/tests/functional/u/unknown_encoding_py29.py) so this should not be happening (?)
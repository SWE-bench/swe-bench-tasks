Hi @crosser, thanks for the report.

> I have no concise reproducer. 

We might be able to help you distill one.

`pylint` produces a crash report, and shows the link in your terminal, like this:
```shell
************* Module a
a.py:1:0: F0002: a.py: Fatal error while checking 'a.py'. Please open an issue in our bug tracker so we address this. There is a pre-filled template that you can use in '/Users/.../Library/Caches/pylint/pylint-crash-2022-10-29-08-48-25.txt'. (astroid-error)
```
The offending file is at the top of the crash report. If the code is too long, or contains sensitive information, you can use the knowledge that the crash happened in `_infer_str_format_call` to look for calls to `.format()` on strings. You should be able to then just provide us those calls--and enough surrounding code to rebuild the objects you provided to `format()`. 

Doing this would be a tremendous help!
> `pylint` produces a crash report, and shows the link in your terminal, like this:

No, not really, it does not. I am attaching a (censored) stderr from running the test. The line in the source code that apparently triggers the problem is pretty innocuous:

```
    @property
    def vnet_id(self):  # <---- this is the line 266 that is mentioned in the "Exception on node" message
        if ...:
```
There is very similar property definition right before this one, that does not trigger the problem.

[pyerr.txt](https://github.com/PyCQA/astroid/files/9900190/pyerr.txt)

Pylint command was `python3 -m pylint --jobs=0 --rcfile=test/style/pylint.conf <project-dir>`

```
$ pylint --version
pylint 2.15.5
astroid 2.12.12
Python 3.10.8 (main, Oct 24 2022, 10:07:16) [GCC 12.2.0]
```

edit:
> enough surrounding code to rebuild the objects you provided to format().

_I_ did not provide any objects to `format()`, astroid did...
Thanks for providing the traceback.

> No, not really, it does not. I am attaching a (censored) stderr from running the test. 

I see now that it's because you're invoking pylint from a unittest, so your test is managing the output.

> The line in the source code that apparently triggers the problem is pretty innocuous:

The deeper failure is on the call in line 268, not the function def on line 266. Is there anything you can sanitize and tell us about line 268? Thanks again for providing the help.
> I see now that it's because you're invoking pylint from a unittest, so your test is managing the output.

When I run pylint by hand

```
pylint --jobs=0 --rcfile=test/style/pylint.conf <module-name> | tee /tmp/pyerr.txt
```
there is still no "Fatal error while checking ..." message in the output

> > The line in the source code that apparently triggers the problem is pretty innocuous:
> 
> The deeper failure is on the call in line 268, not the function def on line 266. Is there anything you can sanitize and tell us about line 268? Thanks again for providing the help.

Oh yes, there is a `something.format()` in that line! But the "something" is a literal string:
```
    @property
    def vnet_id(self):
        if self.backend == "something":
            return "{:04x}{:04x}n{:d}".format(  # <---- this is line 268
                self.<some-attr>, self.<another-attr>, self.<third-attr>
            )
        if self.backend == "somethingelse":
            return "h{:08}n{:d}".format(self.<more-attr>, self.<and more>)
        return None
```

Thanks, that was very helpful. Here is a reproducer:
```python
x = "{:c}".format(None)
```
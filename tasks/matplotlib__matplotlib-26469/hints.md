Sorry to barge in, but this seems related:

```python
from matplotlib import pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

fig = plt.figure()
plt.plot(range(10))
PdfPages('/tmp/foo.pdf').savefig(fig)
```
…happily & silently generates an invalid PDF file like the one described above. The example given in the [documentation for `PdfPages`](https://matplotlib.org/api/backend_pdf_api.html#matplotlib.backends.backend_pdf.PdfPages) *shows* it being used as a context manager, but does not indicate that it can **only** be used as a context manager; nor is there any warning or exception raised. (I think this is also the cause of #9798.)

One solution to my point—but not the original issue—would be to add:

```python
class PdfPages(object):
    # ...

    def __del__(self):
        self.close()
```

Maybe these could be fixed together.
This issue has been marked "inactive" because it has been 365 days since the last comment. If this issue is still present in recent Matplotlib releases, or the feature request is still wanted, please leave a comment and this label will be removed. If there are no updates in another 30 days, this issue will be automatically closed, but you are free to re-open or create a new issue if needed. We value issue reports, and this procedure is meant to help us resurface and prioritize issues that have not been addressed yet, not make them disappear.  Thanks for your help!
@anntzer Do you think this is still worth following up? I‘m inclined to raise instead of doing nothing. („Errors should never pass silently“). - This would also be a simpler deprecation strategy than a suppress_warning kwarg.
Agreed with following up on this.
One problem with emitting an exception is how to combine this (if we want to do so) with https://github.com/matplotlib/matplotlib/issues/11771#issuecomment-440301925, or similarly what behavior do we want for
```python
pdf = PdfPages(...)
# perhaps print a page, or not
# end of program
```
Currently this simply leaves an invalid (single-page missing footer if a page was printed, empty and missing footer if no page was printed) pdf file on disk.  The option suggested by @khaeru (call close() on `__del__`) would make the pdf file valid if a page has been printed, but that means that if no page is printed, then we are trying to throw an exception from within `__del__`, which is a bad idea (https://docs.python.org/3/reference/datamodel.html#object.__del__).

Hence I think the options are
- switch to keep_empty=False, always, ultimately removing support for keep_empty=True (this can be done with a normal deprecation that only affects users that actually rely on the keep_empty=True behavior)
- switch the behavior to "you must use PdfPages as a contextmanager" (wrapping in an ExitStack if you want to use it across multiple functions), deprecating manual calling of close(); this way the exception gets raised in `__exit__` instead, which is not as bad as `__del__` though still not great (you need a try... except around the entire with block if you want to handle that)
- warn instead of raise for empty files -- also not great, as catching warnings is not fun.

Perhaps the first option is the practical one.
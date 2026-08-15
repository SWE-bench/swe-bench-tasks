Related: http://stackoverflow.com/q/25222681/161801

To fix issue #7847 I have done the following changes to the code in sympy/sympy/printing/str.py
Will this work?

``` python
class StrPrinter(Printer):
    printmethod = "_sympystr"
    _default_settings = {
        "order": None,
        "full_prec": "auto",
        "min": None,
        "max": None,
    }
```

``` python
def _print_Float(self, expr):
        prec = expr._prec
        low = self._settings["min"]
        high = self._settings["max"]
        if prec < 5:
            dps = 0
        else:
            dps = prec_to_dps(expr._prec) 
        if self._settings["full_prec"] is True:
            strip = False
        elif self._settings["full_prec"] is False:
            strip = True
        elif self._settings["full_prec"] == "auto":
            strip = self._print_level > 1
        if low is None:
            low = min(-(dps//3), -5)
        if high is None:
            high = dps
        rv = mlib.to_str(expr._mpf_, dps, strip_zeros=strip, min_fixed=low, max_fixed=high)
        if rv.startswith('-.0'):
            rv = '-0.' + rv[3:]
        elif rv.startswith('.0'):
            rv = '0.' + rv[2:]
        return rv
```

@MridulS You should send a pull request for your changes. 

@hargup I just wanted to confirm whether this will work or not.

> I just wanted to confirm whether this will work or not

We can see that at the Pull Request, there we can see the results of the travis build. Also the reviewers will be able to directly pull your changes on the local into their local system. If you have made the changes sending the pull request should not be much work.

@MridulS  Hello the bug has been fixed? 
If not, would like to know more information to resolve this bug. You need help to implement anything else?

@lohmanndouglas You could add @MridulS's github fork of sympy as a remote and pull down his branch with his fix in https://github.com/sympy/sympy/issues/7847. Then play with it and see if it works.

@moorepants unfortunately i have deleted that branch. @lohmanndouglas you can still see the changes I tried at https://github.com/sympy/sympy/commit/61838749a78082453be4e779cb68e88605d49244

Is this issue fixed? I would like to take this on.
@Yathartha22 I think this is still open, if you're still interested --- though it's been a while...

The [SO question that (partially) prompted this has over 1000 views](https://stackoverflow.com/questions/25222681/scientific-exponential-notation-with-sympy-in-an-ipython-notebook) now.
Sure I will take this up.
Is this issue fixed? If not I'd like to work on it.
I don't think so. I don't see any cross-referenced pull requests listed here. 
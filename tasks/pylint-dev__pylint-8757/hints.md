_Original comment by_ **Robert Spier (BitBucket: [robert_spier](http://bitbucket.org/robert_spier))**:

---

And here's the output with formatting fixed.

$ venv/bin/pylint --jobs=2 --rcfile=$PWD/pylintrc app/codein app/melange app/soc app/summerofcode app/settings.py app/urls.py app/main.py tests pavement.py setup.py 2>&1 | head

```
#!text

************* Module codein.callback
W: 17, 0: import missing `from __future__ import absolute_import` (no-absolute-import)
W: 18, 0: import missing `from __future__ import absolute_import` (no-absolute-import)
W: 19, 0: import missing `from __future__ import absolute_import` (no-absolute-import)
W: 20, 0: import missing `from __future__ import absolute_import` (no-absolute-import)
************* Module codein.types
W: 17, 0: import missing `from __future__ import absolute_import` (no-absolute-import)
W: 18, 0: import missing `from __future__ import absolute_import` (no-absolute-import)
W: 20, 0: import missing `from __future__ import absolute_import` (no-absolute-import)
W: 21, 0: import missing `from __future__ import absolute_import` (no-absolute-import)

```

$ venv/bin/pylint --jobs=1 --rcfile=$PWD/pylintrc app/codein app/melange app/soc app/summerofcode app/settings.py app/urls.py app/main.py tests pavement.py setup.py 2>&1 | head

```
#!text

************* Module main
E: 46, 2: print statement used (print-statement)
E: 47, 2: print statement used (print-statement)
E: 48, 2: print statement used (print-statement)
E: 49, 2: print statement used (print-statement)
E: 50, 2: print statement used (print-statement)
************* Module tests.test_utils
E:658, 8: print statement used (print-statement)
E:662,10: print statement used (print-statement)
E:667, 8: print statement used (print-statement)
************* Module tests.run
E:471, 4: print statement used (print-statement)
E:473, 4: print statement used (print-statement)
```

_Original comment by_ **Robert Spier (BitBucket: [robert_spier](http://bitbucket.org/robert_spier))**:

---

FYI, I can also replicate this with the official 1.4.0 release.  Although the output is slightly different.  Running with --jobs=2 produces many more lint warnings than with --jobs=1.

_Original comment by_ **Saulius Menkevičius (BitBucket: [sauliusmenkevicius](http://bitbucket.org/sauliusmenkevicius))**:

---

Can confirm.

For me, pylint seems to ignore the pylintrc file, even though it is specified via the `--rcfile=` option, when -j 2+ is set.

I was using an older version of pylint (with support for --jobs) from `hg+http://bitbucket.org/godfryd/pylint/@763d12c3c923f0733fc5c1866c69d973475993cd#egg=pylint` from this PR: https://bitbucket.org/logilab/pylint/pull-request/82/added-support-for-checking-files-in/commits; which seemed to respect `--pylintrc` properly in multi-process mode. Something broke inbetween that checkin and 1.4.0

_Original comment by_ **Pedro Algarvio (BitBucket: [s0undt3ch](http://bitbucket.org/s0undt3ch), GitHub: @s0undt3ch?)**:

---

I can also confirm this. I had custom plugins on the rcfile and they're not being loaded

_Original comment by_ **Pedro Algarvio (BitBucket: [s0undt3ch](http://bitbucket.org/s0undt3ch), GitHub: @s0undt3ch?)**:

---

I'm also on 1.4.0

_Original comment by_ **Claudiu Popa (BitBucket: [PCManticore](http://bitbucket.org/PCManticore), GitHub: @PCManticore)**:

---

Yeah, --jobs is kind tricky right now, will try to fix asap. By the way, if you have any other problems with --jobs, it's better to open another ticket, so they could be tracked and fixed individually.

_Original comment by_ **Pedro Algarvio (BitBucket: [s0undt3ch](http://bitbucket.org/s0undt3ch), GitHub: @s0undt3ch?)**:

---

I believe my problem is because the rcfile is being ignored.

_Original comment by_ **Michal Nowikowski (BitBucket: [godfryd](http://bitbucket.org/godfryd), GitHub: @godfryd?)**:

---

The issue has been fixed by pull request #213.

_Original comment by_ **Claudiu Popa (BitBucket: [PCManticore](http://bitbucket.org/PCManticore), GitHub: @PCManticore)**:

---

Merged in godfryd/pylint/fix-374 (pull request #213)

Fixed passing configuration from master linter to sublinters. Closes issue #374.

_Original comment by_ **Claudiu Popa (BitBucket: [PCManticore](http://bitbucket.org/PCManticore), GitHub: @PCManticore)**:

---

Merged in godfryd/pylint/fix-374 (pull request #213)

Fixed passing configuration from master linter to sublinters. Closes issue #374.

_Original comment by_ **Claudiu Popa (BitBucket: [PCManticore](http://bitbucket.org/PCManticore), GitHub: @PCManticore)**:

---

Fixed passing configuration from master linter to sublinters. Closes issue #374.

_Original comment by_ **Claudiu Popa (BitBucket: [PCManticore](http://bitbucket.org/PCManticore), GitHub: @PCManticore)**:

---

Hm, the latest patch introduced another regression related to disabling messages from the pylintrc.

_Original comment by_ **Michal Nowikowski (BitBucket: [godfryd](http://bitbucket.org/godfryd), GitHub: @godfryd?)**:

---

How to reproduce that new problem?

I run:
1. pylint **--jobs=2** --rcfile=pylintrc app/codein app/melange app/soc app/summerofcode app/settings.py app/urls.py app/main.py tests pavement.py setup.py 
2. pylint **--jobs=1** --rcfile=pylintrc app/codein app/melange app/soc app/summerofcode app/settings.py app/urls.py app/main.py tests pavement.py setup.py

The outputs contain the same messages. pylintrc is disabling and enabling particular messages.

_Original comment by_ **Claudiu Popa (BitBucket: [PCManticore](http://bitbucket.org/PCManticore), GitHub: @PCManticore)**:

---

Indeed, it was due to a faulty installation. Sorry about the noise.

_Original comment by_ **Robert Spier (BitBucket: [robert_spier](http://bitbucket.org/robert_spier))**:

---

I confirm that it works correctly on the Melange codebase.  The performance improvement from adding more jobs is not as high as expected.  

_Original comment by_ **Pavel Roskin (BitBucket: [pavel_roskin](http://bitbucket.org/pavel_roskin))**:

---

The issue with absolute_import may be resolved by pull request #229. The performance is discussed in issue #479. There are still issues with different output. Not sure if I should open another ticket. I'll describe it here.

_Original comment by_ **Pavel Roskin (BitBucket: [pavel_roskin](http://bitbucket.org/pavel_roskin))**:

---

That's a minimal example showing that the issue is not fully resolved.

```
#!shell

echo 'pass' > first.py
echo 'pass' > second.py
pylint first.py second.py >output1
pylint --jobs=2 first.py second.py >output2
diff -u output1 output2
```

```
#!diff

--- output1 2015-02-25 18:51:36.770036133 -0500
+++ output2 2015-02-25 18:51:39.274040857 -0500
@@ -6,7 +6,7 @@

 Report
 ======
-3 statements analysed.
+4 statements analysed.

 Statistics by type
 ------------------
@@ -72,31 +72,18 @@



-% errors / warnings by module
------------------------------
-
-+-------+------+--------+---------+-----------+
-|module |error |warning |refactor |convention |
-+=======+======+========+=========+===========+
-|second |0.00  |0.00    |0.00     |50.00      |
-+-------+------+--------+---------+-----------+
-|first  |0.00  |0.00    |0.00     |50.00      |
-+-------+------+--------+---------+-----------+
-
-
-
 Messages
 --------

 +------------------+------------+
 |message id        |occurrences |
 +==================+============+
-|missing-docstring |2           |
+|missing-docstring |1           |
 +------------------+------------+



 Global evaluation
 -----------------
-Your code has been rated at 3.33/10 (previous run: 3.33/10, +0.00)
+Your code has been rated at 5.00/10 (previous run: 3.33/10, +1.67)

```

_Original comment by_ **James Broadhead (BitBucket: [jamesbroadhead](http://bitbucket.org/jamesbroadhead), GitHub: @jamesbroadhead?)**:

---

Same here -- getting significantly more 'duplicate-code' & 'cyclic-import' with --jobs=1 over --jobs=2

Closed-source codebase, but I'm happy to run debug branches etc.  over it. 

$ pylint --version
pylint 1.4.4, 
astroid 1.3.6, common 1.0.2
Python 2.7.8 (default, Sep 10 2014, 04:44:11) 
[GCC 4.9.1]

_Original comment by_ **Claudiu Popa (BitBucket: [PCManticore](http://bitbucket.org/PCManticore), GitHub: @PCManticore)**:

---

Increasing to blocker, so that we'll have a fix finally in 1.5.

_Original comment by_ **Claudiu Popa (BitBucket: [PCManticore](http://bitbucket.org/PCManticore), GitHub: @PCManticore)**:

---

I'm trying to reproduce this issue, but unfortunately I can't reproduce Pavel's example using the latest code from the repository. Could anyone of you provide a more comprehensive example where this discrepancy happens?

_Original comment by_ **Pavel Roskin (BitBucket: [pavel_roskin](http://bitbucket.org/pavel_roskin))**:

---

I tried pylint on the current python-ly, and I see that things have improved greatly. There are only two issues that the parallel pylint missed compared to the single-job version: `R0401(cyclic-import)` and `R0801(duplicate-code)`. There is also a discrepancy in the way `__init__.py` is referred to.

One job:

```
************* Module ly
ly/__init__.py(46): [C0303(trailing-whitespace)] Trailing whitespace
```

Two jobs:

```
************* Module ly.__init__
ly/__init__.py(46): [C0303(trailing-whitespace)] Trailing whitespace
```

I actually prefer the later notation, it's more explicit that it's just the `__init__.py` file, not the whole module.

_Original comment by_ **Pavel Roskin (BitBucket: [pavel_roskin](http://bitbucket.org/pavel_roskin))**:

---

Here's a simple test for the module naming issue. It turns out the parallel version uses both names, which is bad.

```
[proski@dell pylinttest]$ echo "pass " >__init__.py
[proski@dell pylinttest]$ pylint -r n --jobs=1 .
************* Module pylinttest
C:  1, 0: Trailing whitespace (trailing-whitespace)
C:  1, 0: Missing module docstring (missing-docstring)
[proski@dell pylinttest]$ pylint -r n --jobs=2 .
************* Module pylinttest.__init__
C:  1, 0: Trailing whitespace (trailing-whitespace)
************* Module pylinttest
C:  1, 0: Missing module docstring (missing-docstring)
```

_Original comment by_ **Pavel Roskin (BitBucket: [pavel_roskin](http://bitbucket.org/pavel_roskin))**:

---

Cyclic import problem

```
:::text
[proski@dell pylintcycle]$ touch __init__.py
[proski@dell pylintcycle]$ echo 'import pylintcycle.second' >first.py
[proski@dell pylintcycle]$ echo 'import pylintcycle.first' >second.py
[proski@dell pylintcycle]$ pylint -r n --jobs=1 first.py second.py
************* Module pylintcycle.first
C:  1, 0: Missing module docstring (missing-docstring)
W:  1, 0: Unused import pylintcycle.second (unused-import)
************* Module pylintcycle.second
C:  1, 0: Missing module docstring (missing-docstring)
W:  1, 0: Unused import pylintcycle.first (unused-import)
R:  1, 0: Cyclic import (pylintcycle.first -> pylintcycle.second) (cyclic-import)
[proski@dell pylintcycle]$ pylint -r n --jobs=2 first.py second.py
************* Module pylintcycle.first
C:  1, 0: Missing module docstring (missing-docstring)
W:  1, 0: Unused import pylintcycle.second (unused-import)
************* Module pylintcycle.second
C:  1, 0: Missing module docstring (missing-docstring)
W:  1, 0: Unused import pylintcycle.first (unused-import)
```

_Original comment by_ **Pavel Roskin (BitBucket: [pavel_roskin](http://bitbucket.org/pavel_roskin))**:

---

When running `pylint -rn --jobs=2 pylint` in an empty directory, following issue is reported:

```
:::text
************* Module pylint.lint
E:978,15: Instance of 'Values' has no 'persistent' member (no-member)
```

The single-job version does not detect that condition.

_Original comment by_ **Claudiu Popa (BitBucket: [PCManticore](http://bitbucket.org/PCManticore), GitHub: @PCManticore)**:

---

Thank you for the detailed reports, Pavel. Will look soon.

_Original comment by_ **Claudiu Popa (BitBucket: [PCManticore](http://bitbucket.org/PCManticore), GitHub: @PCManticore)**:

---

Regarding `pylint -rn --jobs=2 pylint`, this happens because there's no configuration files which disables the corresponding messages for pylint, such as the one from pylint/pylintrc. I can reproduce it with both the single-job version and with multiple jobs, it's actually expected.

Late to the game and new to pylint, and I feel I'm running into this issue. I'm a little confused, though, since even very simple cases seem to break with `-j2`. 

```
$ cat > lint_test.py <<EOF
def f(x):
 return x # 1 space
EOF

$ cat > pylintrc <<EOF
[MESSAGES CONTROL]
disable=all
enable=bad-indentation
EOF

$ pylint --version
pylint 1.6.1, 
astroid 1.4.7
Python 2.7.11 |Anaconda 2.3.0 (x86_64)| (default, Dec  6 2015, 18:57:58) 
[GCC 4.2.1 (Apple Inc. build 5577)]

$ pylint -rn lint_test.py 
************* Module lint_test
W:  2, 0: Bad indentation. Found 1 spaces, expected 4 (bad-indentation)

$ pylint -rn lint_test.py -j1
************* Module lint_test
W:  2, 0: Bad indentation. Found 1 spaces, expected 4 (bad-indentation)

$ pylint -rn lint_test.py -j2
<no output>
```

I don't see a way this can be expected behavior. Am I missing something? Am I using the tool fundamentally wrong?

Hi @rdadolf 

This bug is definitely irritating, I don't remember exactly why it got stuck, I should check again if it works.

For me your example works perfectly. Do you have any pylintrc in that directory or somewhere else, which could potentially interfere with Pylint? I tried the same configuration, on Windows. Did you try on another OS? Does it work with multiple jobs and can you test with multiple files? 

I sometimes forget that there are developers who use non-unix systems. It's possible that differences in process scheduling are at play here.

No other configuration files were in that directory, nor do I have a user-wide config file in my home directory.

The system above was OS X 10.11.3 running an Anaconda version of python (as shown in the `--version` output).

I just tried the same thing on an Ubuntu 15.10 machine which pylint was not previously installed. Used `pip install pylint` with no other actions, ran the same commands as above in a new scratch directory and I'm seeing the same behavior.

All values for `N>1` with `-jN` seem to produce the same result (i.e., they fail to report anything).

Not sure what you mean by this last request, though:

> Does it work with multiple jobs and can you test with multiple files?

The problem is identical for a multi-file module, if that's what you're asking. This setup:

```
$ ls -R
.:
lint_test  pylintrc

./lint_test:
__init__.py  lint_f.py  lint_g.py

$ cat lint_test/*.py
# __init__.py
from lint_f import f
from lint_g import g
# lint_f.py
def f(x):
 return x # 1 space
# lint_g.py
def g(x):
 return x # 1 space
```

I.e., a module with two source files and a simple `__init__.py`, also shows the same symptoms (same config file as before):

```
$ pylint -rn lint_test/
************* Module lint_test.lint_g
W:  3, 0: Bad indentation. Found 1 spaces, expected 4 (bad-indentation)
************* Module lint_test.lint_f
W:  3, 0: Bad indentation. Found 1 spaces, expected 4 (bad-indentation)
$ pylint -rn lint_test/ -j1
************* Module lint_test.lint_g
W:  3, 0: Bad indentation. Found 1 spaces, expected 4 (bad-indentation)
************* Module lint_test.lint_f
W:  3, 0: Bad indentation. Found 1 spaces, expected 4 (bad-indentation)
$ pylint -rn lint_test/ -j2
<no output>
```

Okay, I think I know why this is happening. Apparently the issue happens whenever we are disabling all the categories and enabling only a handful of messages in the configuration. For instance, you can try to add some new errors into your code and test with disable=E instead, you will still receive the messages for bad-indentation.

I'll have to check what is happening and fix it.

I think it might be a little more than that. The following also doesn't work:

```
$ pylint -rn lint_test.py --disable=W --enable=bad-indentation
************* Module lint_test
W:  2, 0: Bad indentation. Found 1 spaces, expected 4 (bad-indentation)
C:  1, 0: Missing module docstring (missing-docstring)
C:  1, 0: Invalid function name "f" (invalid-name)
C:  1, 0: Invalid argument name "x" (invalid-name)
C:  1, 0: Missing function docstring (missing-docstring)

$ pylint -rn lint_test.py --disable=W --enable=bad-indentation -j2
************* Module lint_test
C:  1, 0: Missing module docstring (missing-docstring)
C:  1, 0: Invalid function name "f" (invalid-name)
C:  1, 0: Invalid argument name "x" (invalid-name)
C:  1, 0: Missing function docstring (missing-docstring)
```

Same behavior if you put it in a pylintrc:

```
$ cat > pylintrc <<EOF
[MESSAGES CONTROL]
disable=W
enable=bad-indentation
EOF
```

So it's not just when all the categories are disabled. It's possible that the trigger is when the two conditions overlap, but I haven't tested it thoroughly.

I believe this is happening as `_all_options` (which is what `_get_jobs_config` uses to populate a fresh dictionary from the current options for child tasks) is populated from `PyLinter.options` before the config file is read.
That means that anything defined in in `.options` will come first in `_all_options`, which will probably be the wrong order for sub tasks, and break options that are order dependent (enable/disable).
@PCManticore I'm unsure of whether this approach is ideal.
Basically, we could keep track of each option being set in its raw form, which would allow us to do a playback of configs passed in.

I'm not sure if it would account for multiple instances of `--enable|disbable` (due to not knowing of optparse provides access to individual arguments). doing ```pylint --disable=all --enable=E --disable=E``` Should (and currently does) disable all checkers.


We could also just add a hidden option that is manipulated in the `enable` and `disable` methods to always contain the cumulative of checkers to run, however that would result in storing the same state in at least 2 places.

Fixing this issue will break people's setups that depend on `enable` always going before `disable` for multiple jobs, however I doubt that's in issue.

I'm around on #pylint@freenode if you want to chat
pylint 1.7.2, 
astroid 1.5.3
Python 3.6.2 |Anaconda custom (64-bit)| (default, Jul 20 2017, 13:51:32) 
[GCC 4.4.7 20120313 (Red Hat 4.4.7-1)]
no pylintrc

I'm seeing big differences on a large code base between -j 1 and -j N. I also see slight differences between -j 2 and -j 8 of the form:
`[R0902(too-many-instance-attributes), Ethernet] Too many instance attributes (14/7)`
vs
`[R0902(too-many-instance-attributes), Ethernet] Too many instance attributes (13/7)`
where the '14/7' comes from the -j 2 run and the '13/7' comes from the -j 8 run.

But with -j 1 I get several `R0401(cyclic-import)` errors with -j 1, but none with -j 2 or -j 8. And when I repeat the runs with -j 1 back-to-back on the CL, the number of R0401 errors changes from run to run; from one run to the next, some R0401 flags disappear while other new ones appear! This behavior makes my Jenkins tracking go crazy.
Also having issues with `duplicate-code` message (on closed-source code):
```
pylint 1.8.4,
astroid 1.6.3
Python 3.6.3 (default, Oct  3 2017, 21:45:48)
[GCC 7.2.0]
```

When running with `-j 2`, duplication is not detected; When running with `-j 1`, issues found.

I'm guessing this checker specifically has a different issue with multi-jobs, because it needs to see "all" the code, vs just one file at a time like most simpler checkers, so it would need to be solved differently.
We are likely going to have to deal with this as part of the per directory config project. Checkers used to be created more than once only when `jobs` was anything higher than one. Now that checkers are going to be created per directory, they will need to share state between instances of themselves. Accesses to the shared state are going to need to be thread safe for this model to work in a parallel context as well.
Hi,
This is still an issue on pylint 2.3.1. Any estimate on when it will be fixed? Deterministic output is crucial for CI checks!
@carlosgalvezp This is a volunteer driven project. I cannot offer any estimates for when an issue is going to be fixed as we're already overstrained with our time for all the 500+ issues you're seeing in this bug tracker. If you want an issue to be solved faster, finding ways to contribute would be the way to go, either by submitting patches, or by financially contributing to the project.
Just sharing that I'm seeing the issue - specifically on similarity checks - on two flavours of pylint 2.4. Given the amount of head-scratching time I spent on this, if I get a second I might have a look at the cause.

### version1
pylint 2.4.4
astroid 2.3.3
Python 3.7.6 (default, Jan 30 2020, 09:44:41) 
[GCC 9.2.1 20190827 (Red Hat 9.2.1-1)]

### version2
PYLINT VER: pylint 2.4.2
PYLINT VER: astroid 2.3.1
PYLINT VER: Python 3.7.4 (default, Oct  2 2019, 14:13:54) 
PYLINT VER: [GCC 8.3.0]

This issue looks to be caused by by the fact that `check_parallel()` calls `_worker_check_single_file()`, creating individual linters per-file, rather than a single linter for all files (which is what we do in the single-threaded mode).

My suggestion would be to have `_worker_check_single_file()` return some data structure representing multi-threaded, recombinable data e.g. `_worker_linter._mt_merge_data` which would contain all `LineSets` in the `SimilarChecker` case and None otherwise. That would require adding a step after the `imap_unordered()`, passing all SimilarChecker data to some `clasmethod` (?) on `SimilarChecker`. We could use a mixin or attribute checking on the linters to determine if this is supported/desired.

The above would allow threadable work to be done, but would also allow plugins like SimilarChecker to use global data as/when needed. So, distribute the file-parsing, single-threading the actual similarity check, I'm not sure if the cartesian-product work could be threaded...

It wouldn't take too long to implement a prototype (and I'd have it done by now if I could get tox to work in my local checkout - if I get a second later I'll have another punt at it).
I think I have a working fix for this, using a map/reduce paradigm for checkers. I will submit the PR tomorrow after I've given the code another once-over.
This should be fixed by the map reduce implementation done by @doublethefish and merged in #4007. Thanks a lot !
Reopening because only the duplicate checker was fixed, the MapreduceMixin still need to be applied where it makes sense, for example for cyclic import check like in #2573 
Adding a reproducer from [a duplicate issue](https://github.com/PyCQA/pylint/issues/4171#issue-819663484):

Running `pylint -jobs=0` does not report about cyclic-import. This can be reproduced with a trivial example.
`a.py`:
```
import b
```
`b.py`:
```
import a
```
I'm sorry to unearth this, but `duplicate-code` is still not shown with `-j 2` with
```
pylint 2.14.4
astroid 2.11.7
Python 3.10.5 (main, Jun  6 2022, 18:49:26) [GCC 12.1.0]
```
Which specific variant of duplicate code; in-file or across files?
Only across files
Can you share an example of two files that fail? I'll add it to the tests (which I am assuming are still working and do test -j2-10 on similar files).
I guess there is nothing special about such files -- any similar lines in 2 files really:
```
$ cat bin/1.py
1
2
3
4
5
6
```
same for bin/2.py.
```
$ pylint bin/1.py bin/2.py 
...
bin/2.py:1:0: R0801: Similar lines in 2 files
==1:[0:6]
==2:[0:6]
1
2
3
4
5
6 (duplicate-code)
```
I experience the same behaviour (Pylint `2.15.0`, Python `3.8.13`). This behaviour seems to affect any check for which context is spread across files (cyclical imports, duplicate code).

At first I thought this was because input files were checked across different parallel workers, and therefore important context from a secondary file (e.g. duplicate code) was outside the context of the parallel worker. I don't think this is the case though; even when files are processed on the same worker (but jobs>1), the same behaviour is observed.

I think this has more to do with the different ways in which files are handled between [serial](https://github.com/PyCQA/pylint/blob/main/pylint/lint/pylinter.py#L676-L691) and [parallel](https://github.com/PyCQA/pylint/blob/main/pylint/lint/pylinter.py#L664-L673) execution (determined by the number of jobs). For example, for files `foo` and `bar`, I observed the similarity linter running twice for each file in parallel, but once for all files in serial. Of course if the similarity linter lints only `foo`, it will miss code duplicated in `bar`.

Another example not yet mentioned is `invalid-name`. `test1.py`:

```python
'''
Docstring
'''

class Test:
    '''
    Test Class
    '''

    CLASS_ATTR = 5

```

`test2.py`:

```python
'''
Docstring
'''
from test1 import Test

x = Test()
x.CLASS_ATTR = 3

```

```
~ % pylint --jobs=0 test1.py test2.py

--------------------------------------------------------------------
Your code has been rated at 10.00/10 (previous run: 10.00/10, +0.00)
```

```
~ % pylint --jobs=1 test1.py test2.py
************* Module test2
test2.py:7:0: C0103: Attribute name "CLASS_ATTR" doesn't conform to snake_case naming style (invalid-name)

-------------------------------------------------------------------
Your code has been rated at 8.00/10 (previous run: 10.00/10, -2.00)
```
I just lost a ton of time trying to debug why I was getting different results on CI than I was in any other environment even though the same Docker images were used both locally and on CI.  Finally I found out it was because I had `jobs = 0` to auto-detect the number of CPUs/cores and the CI runner had only one CPU.  When I set `jobs = 1` I got the same results in all environments.  And it wasn't just "cyclical imports, duplicate code" checks, other errors were reported only in CI as well.

 At the very least, I think [the Parallel execution docs](https://pylint.readthedocs.io/en/latest/user_guide/usage/run.html#parallel-execution) should include a big red flashing light to warn other developers who might get bitten by this. 
> I just lost a ton of time trying to debug why I was getting different results on CI than I was in any other environment even though the same Docker images were used both locally and on CI. Finally I found out it was because I had `jobs = 0` to auto-detect the number of CPUs/cores and the CI runner had only one CPU. When I set `jobs = 1` I got the same results in all environments. And it wasn't just "cyclical imports, duplicate code" checks, other errors were reported only in CI as well.
> 
> At the very least, I think [the Parallel execution docs](https://pylint.readthedocs.io/en/latest/user_guide/usage/run.html#parallel-execution) should include a big red flashing light to warn other developers who might get bitten by this.

I've also been battling really odd behaviour in CI when everything was running fine locally (in docker or otherwise). Changing jobs to `0` was what fixed it to me however (for some reason I had it set to `8` 🤷)
it's easy to repro:

 - have a massive code base, with lots of files
 - run pylint in parallel
 - get spurious errors

pylint with 1 core (jobs==1) never has this issue, but is way too slow for large code bases
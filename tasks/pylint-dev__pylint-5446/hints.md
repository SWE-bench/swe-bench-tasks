_Original comment by_ **Radek Holý (BitBucket: [PyDeq](http://bitbucket.org/PyDeq), GitHub: @PyDeq?)**:

---

Pylint marks even import blocks as duplicates. In my case, it is:

```
#!python
import contextlib
import io
import itertools
import os
import subprocess
import tempfile

```

I doubt it is possible to clean up/refactor the code to prevent this, thus it would be nice if it would ignore imports or if it would be possible to use the disable comment.

_Original comment by_ **Buck Evan (BitBucket: [bukzor](http://bitbucket.org/bukzor), GitHub: @bukzor?)**:

---

I've run into this today.

My project has several setup.py files, which of course look quite similar, but can't really share code.
I tried to `# pylint:disable=duplicate-code` just the line in question (`setup()`), but it did nothing.

I'll have to turn the checker off entirely I think.

any news on this issue ?

No one is currently working on this. This would be nice to have fixed, but unfortunately I didn't have time to look into it. A pull request would be appreciated though and would definitely move it forward.

@gaspaio 
FYI I have created a fix in the following PR https://github.com/PyCQA/pylint/pull/1055
Could you check if It work for you?

Is this related to duplicate-except? it cannot be disabled either. 

sorry, Seems it is able to be disabled.
@PCManticore as you mentioned, there is probably no good way to fix this issue for this version; What about fixing this in a "[bad way](https://github.com/PyCQA/pylint/pull/1055)" for this version, and later on in the planned version 3 you can [utilize a better engineered two-phase design](https://github.com/PyCQA/pylint/pull/1014#issuecomment-233185403) ?

While sailing, sometimes the only way to fix your ship is ugly patching, and it's better than not fixing.
A functioning tool is absolutely better than a "perfectly engineered" tool.
> A functioning tool is absolutely better than a "perfectly engineered" tool.

It's better because it exists, unlike perfect engineering :D
Is this issue resolved? I'm using pylint 2.1.1 and cannot seem to disable the warning with comments in the files which are printed in the warning.
Hi @levsa 
I have created a custom patch that you can use locally from:
 - https://github.com/PyCQA/pylint/pull/1055#issuecomment-384382126

We are using it 2.5 years ago and it is working fine.

The main issue is that the `state_lines` are not propagated for the methods used.
This patch just propagates them correctly.

You can use:
```bash
wget -q https://raw.githubusercontent.com/Vauxoo/pylint-conf/master/conf/pylint_pr1055.patch -O pylint_pr1055.patch
patch -f -p0 $(python -c "from __future__ import print_function; from pylint.checkers import similar; print(similar.__file__.rstrip('c'))") -i pylint_pr1055.patch
```
@moylop260 Your fix doesn't work. Even if I have `# pylint: disable=duplicate-code` in each file with duplicate code, I still get errors.
You have duplicated comments too.
Check answer https://github.com/PyCQA/pylint/pull/1055#issuecomment-470572805
Still have this issue on pylint = "==2.3.1"
The issue still there for latest python 2 pylint version 1.9.4

`# pylint: disable=duplicate-code` does not work, while # pylint: disable=all` can disable the dup check.
Also have this issue with `pylint==2.3.1`

Even if i add the the pragma in every file with duplicate code like @filips123, i still get the files with the pragma reported ....

Any progress on this? I don't want to `# pylint: disable=all` for all affected files ...
I am using pylint 2.4.0 for python 3 and I can see that `disable=duplicate-code` is working.
I'm using pylint 2.4.4 and `# pylint: disable=duplicate-code` is not working for me.
Also on `2.4.4`
And on 2.4.2
another confirmation of this issue on 2.4.4
Not working for me `# pylint: disable=duplicate-code` at 2.4.4 version python 3.8
Also **not** woking at 2.4.4 with python 3.7.4 and `# pylint: disable=R0801` or `# pylint: disable=duplicate-code`
Also doesn't work. pylint 2.4.4, astroid 2.3.3, Python 3.8.2
I found a solution to partially solve this.

https://github.com/PyCQA/pylint/pull/1055#issuecomment-477253153

Use pylintrc. Try changing the `min-similarity-lines` in the similarities section of your pylintrc config file.

```INI
[SIMILARITIES]

# Minimum lines number of a similarity.
min-similarity-lines=4

# Ignore comments when computing similarities.
ignore-comments=yes

# Ignore docstrings when computing similarities.
ignore-docstrings=yes

# Ignore imports when computing similarities.
ignore-imports=no
```


+1
Happened to me on a overloaded method declaration, which is obviously identical as its parent class, and in my case its sister class, so pylint reports "Similar lines in 3 files" with the `def` and its 4 arguments (spanning on 6 lines, I have one argument per line due to type anotations).

It think this could be mitigated by whitelisting import statements and method declaration.
Just been bitten by this issue today.

> pylint 2.6.0
astroid 2.4.2
Python 3.9.1 (default, Jan 20 2021, 00:00:00) 

Increasing `min-similarity-lines` is not actually a solution, as it will turn off duplicate code evaluation.
In my particular case I had two separate classes with similar inputs in the `def __init__`

As a workaround and what worked for me was to include the following in our pyproject.toml (which is the SIMILARITIES section if you use pylinr.rc):
```
[tool.pylint.SIMULARITIES]
ignore-comments = "no"
```

Doing this then allows pylint to not disregard the comments on lines. From there we added the `# pylint: disable=duplicate-code` to the end of one of the lines which now made this "unique" (although you could in practice use any comment text)

This is a better temporary workaround than the `min-similarity-lines` option as that:
* misses other instance where you'd want that check
* also doesnt return with a valid exit code even though rating is 10.00/10
it is possible now with file pylint.rc with disable key and value duplicate-code, this issue can be closed and solve in my opnion #214
> it is possible now with file pylint.rc with disable key and value duplicate-code, this issue can be closed and solve in my opnion #214

The main issue is not being able to use `# pylint: disable=duplicate-code` to exclude particular blocks of code. Disabling `duplicate-code` all together is not an acceptable solution. 
Since the issue was opened we added multiple option to ignore import, ignore docstrings and ignore signatures, so there is less and less reasons to want to disable it. But the problem still exists.
So any idea how to exclude particular blocks of code from the duplicated code checks without disabling the whole feature?
> So any idea how to exclude particular blocks of code from the duplicated code checks without disabling the whole feature?

Right now there isn't, this require a change in pylint.
any news about this? It looks like many people have been bitten by this and it's marked as high prio
thanks
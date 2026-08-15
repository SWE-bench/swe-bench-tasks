I cannot reproduce this locally. 🤯  The error log above looks like some lines moved about... but it does not make sense.

Also, to run this in an interactive session:

```python
import numpy as np
from astropy import units as u
from astropy.table import QTable

T = QTable.read(
        [
            " a b c d",
            " 2 c 7.0 0",
            " 2 b 5.0 1",
            " 2 b 6.0 2",
            " 2 a 4.0 3",
            " 0 a 0.0 4",
            " 1 b 3.0 5",
            " 1 a 2.0 6",
            " 1 a 1.0 7",
        ],
        format="ascii",
)
T["q"] = np.arange(len(T)) * u.m
T.meta.update({"ta": 1})
T["c"].meta.update({"a": 1})
T["c"].description = "column c"
T.add_index("a")

t1 = QTable(T, masked=True)
tg = t1.group_by("a")
```
```python
>>> tg
<QTable length=8>
  a    b      c      d      q
                            m
int64 str1 float64 int64 float64
----- ---- ------- ----- -------
    0    a     0.0     4     4.0
    1    b     3.0     5     5.0
    1    a     2.0     6     6.0
    1    a     1.0     7     7.0
    2    c     7.0     0     0.0
    2    b     5.0     1     1.0
    2    b     6.0     2     2.0
    2    a     4.0     3     3.0
```
@pllim - I also cannot reproduce the problem locally on my Mac. What to do?
@taldcroft , does the order matter? I am guessing yes?

Looks like maybe somehow this test triggers some race condition but only in CI, or some global var is messing it up from a different test. But I don't know enough about internals to make a more educated guess.
What about this: could the sort order have changed? Is the test failure on an "AVX-512 enabled processor"?

https://numpy.org/devdocs/release/1.25.0-notes.html#faster-np-sort-on-avx-512-enabled-processors
Hmmm.... maybe?

* https://github.com/actions/runner-images/discussions/5734
@pllim - Grouping is supposed to maintain the original order within a group. That depends on the numpy sorting doing the same, which depends on the specific sort algorithm.
So that looks promising. Let me remind myself of the code in there...
So if we decide that https://github.com/numpy/numpy/pull/22315 is changing our result, is that a numpy bug?
It turns out this is likely in the table indexing code, which is never easy to understand. But it does look like this is the issue, because indexing appears to use the numpy default sorting, which is quicksort. But quicksort is not guaranteed to be stable, so maybe it was passing accidentally before.
I cannot reproduce this locally. 🤯  The error log above looks like some lines moved about... but it does not make sense.

Also, to run this in an interactive session:

```python
import numpy as np
from astropy import units as u
from astropy.table import QTable

T = QTable.read(
        [
            " a b c d",
            " 2 c 7.0 0",
            " 2 b 5.0 1",
            " 2 b 6.0 2",
            " 2 a 4.0 3",
            " 0 a 0.0 4",
            " 1 b 3.0 5",
            " 1 a 2.0 6",
            " 1 a 1.0 7",
        ],
        format="ascii",
)
T["q"] = np.arange(len(T)) * u.m
T.meta.update({"ta": 1})
T["c"].meta.update({"a": 1})
T["c"].description = "column c"
T.add_index("a")

t1 = QTable(T, masked=True)
tg = t1.group_by("a")
```
```python
>>> tg
<QTable length=8>
  a    b      c      d      q
                            m
int64 str1 float64 int64 float64
----- ---- ------- ----- -------
    0    a     0.0     4     4.0
    1    b     3.0     5     5.0
    1    a     2.0     6     6.0
    1    a     1.0     7     7.0
    2    c     7.0     0     0.0
    2    b     5.0     1     1.0
    2    b     6.0     2     2.0
    2    a     4.0     3     3.0
```
@pllim - I also cannot reproduce the problem locally on my Mac. What to do?
@taldcroft , does the order matter? I am guessing yes?

Looks like maybe somehow this test triggers some race condition but only in CI, or some global var is messing it up from a different test. But I don't know enough about internals to make a more educated guess.
What about this: could the sort order have changed? Is the test failure on an "AVX-512 enabled processor"?

https://numpy.org/devdocs/release/1.25.0-notes.html#faster-np-sort-on-avx-512-enabled-processors
Hmmm.... maybe?

* https://github.com/actions/runner-images/discussions/5734
@pllim - Grouping is supposed to maintain the original order within a group. That depends on the numpy sorting doing the same, which depends on the specific sort algorithm.
So that looks promising. Let me remind myself of the code in there...
So if we decide that https://github.com/numpy/numpy/pull/22315 is changing our result, is that a numpy bug?
It turns out this is likely in the table indexing code, which is never easy to understand. But it does look like this is the issue, because indexing appears to use the numpy default sorting, which is quicksort. But quicksort is not guaranteed to be stable, so maybe it was passing accidentally before.
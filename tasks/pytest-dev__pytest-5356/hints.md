Can you add `-rs` (it should add additional reporting information about skipped tests)
This appears to be the minimal case to reproduce this:

```python
import itertools

import pytest

AS = (1, 2, 3)
BS = (4, 5, 6)


@pytest.mark.parametrize(('a', 'b'), itertools.product(AS, BS))
def test(a, b):
    pass
```

A workaround is to apply this diff:

```diff
-@pytest.mark.parametrize(('a', 'b'), itertools.product(AS, BS))
+@pytest.mark.parametrize(('a', 'b'), tuple(itertools.product(AS, BS)))
```

looking now to see what regressed this 🤔 
There should be a warning 
w/ `-rs` it produces this:

```console
$ pytest t.py -rs
============================= test session starts ==============================
platform linux -- Python 3.6.7, pytest-4.6.0, py-1.8.0, pluggy-0.12.0
rootdir: /home/asottile/workspace/pyupgrade
collected 1 item                                                               

t.py s                                                                   [100%]

=========================== short test summary info ============================
SKIPPED [1] t.py:9: got empty parameter set ('a', 'b'), function test at /home/asottile/workspace/pyupgrade/t.py:8
========================== 1 skipped in 0.01 seconds ===========================
```
Looks like this regressed in https://github.com/pytest-dev/pytest/pull/5254  CC @Sup3rGeo
@asottile Thank you! Workaround does just fine. Here is output with `-rs` option if still needed: https://travis-ci.org/Snawoot/postfix-mta-sts-resolver/jobs/540200985
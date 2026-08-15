As a workaround I'm currently explicitly setting `basetemp` for every test process.
Experiencing similar issue. Here's my environment:
`platform linux -- Python 3.6.8, pytest-4.0.2, py-1.8.0, pluggy-0.9.0`
`plugins: xdist-1.25.0, ordering-0.6, forked-1.0.2`
For people looking for a workaround, I found creating a fixture in conftest.py as follow to help:

```python
from tempfile import TemporaryDirectory
import pytest
@pytest.fixture(scope="session", autouse=True)
def changetmp(request):
    with TemporaryDirectory(prefix="pytest-<project-name>-") as temp_dir:
        request.config.option.basetemp = temp_dir
        yield
```

This basically makes each of the processes in xdist to create everything in a temporary folder. It will though delete everything after it ends.
Still happening for me, much more frequent now, latest current version of pytest, 5.3.5.
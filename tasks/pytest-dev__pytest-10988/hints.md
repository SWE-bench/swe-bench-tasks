Thanks for the report @jdckmz! 
From what I can tell, if we have got to this point there is no pluginmanager has picked up the command line arg, so is there really anything we can do?
The args that I've added aren't part of a plugin but are [part of pytest itself as I understand, documented here](https://docs.pytest.org/en/7.1.x/example/simple.html#pass-different-values-to-a-test-function-depending-on-command-line-options):
In `conftest.py`:
```python
def pytest_addoption(parser):
    """pytest hook to add command line options."""

    group = parser.getgroup("Canvas Test Options")
    group.addoption(
        "--xxxxx_flags",
        default=None,
        help="Extra flags to pass to the launched process.",
    )
@jdckmz 

Ok after some investigation, you need to make `--xxxxx_flags` into a `pytest.fixture` for it to not register as a path
Thanks for the report @jdckmz! 
From what I can tell, if we have got to this point there is no pluginmanager has picked up the command line arg, so is there really anything we can do?
The args that I've added aren't part of a plugin but are [part of pytest itself as I understand, documented here](https://docs.pytest.org/en/7.1.x/example/simple.html#pass-different-values-to-a-test-function-depending-on-command-line-options):
In `conftest.py`:
```python
def pytest_addoption(parser):
    """pytest hook to add command line options."""

    group = parser.getgroup("Canvas Test Options")
    group.addoption(
        "--xxxxx_flags",
        default=None,
        help="Extra flags to pass to the launched process.",
    )
@jdckmz 

Ok after some investigation, you need to make `--xxxxx_flags` into a `pytest.fixture` for it to not register as a path
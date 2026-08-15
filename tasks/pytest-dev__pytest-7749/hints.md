Note this also happens when e.g. trying to define a fixture but forgetting to import `pytest`:

```python
@pytest.fixture
def myvalue():
    return 42

def test_myvalue(myvalue):
    assert myvalue == 42
```
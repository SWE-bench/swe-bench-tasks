Allow to search a list of elements in a `FileSet` while only loading instances once, to drastically improve execution time
**Is your feature request related to a problem? Please describe.**
Currently, `fileset.FileSet.find_values` only allows for elements to be searched for one at a time. When executing this action while setting `load` to `True`, this results in a substantial overhead.

**Describe the solution you'd like**
The following example code allows loading the instances once, and iterating over a list of elements to find:
```python
def find_values_quick(self, elements, instances=None):
    results = {element: [] for element in elements}
    instances = instances or iter(self)
    for instance in instances:
        instance = instance.load()
        for element in elements:
            if element not in instance:
                continue
            val = instance[element].value
            if val not in results[element]:
                results[element].append(val)
    return results
```

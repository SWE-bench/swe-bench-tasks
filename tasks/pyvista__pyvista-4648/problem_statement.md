Clean up and clarify sampling-like filters
### Describe what maintenance you would like added.

There was a discussion on slack on the use of sampling-like filters, i.e. `sample`, `probe`, and `interpolate`.  One issue is that it is hard to figure out when to use which filter.  The other issue is that `probe` has the opposite behavior of `sample` and `interpolate` in regards to order of operation (see below).

### Links to source code.

_No response_

### Pseudocode or Screenshots

```python
import pyvista as pv

small = pv.ImageData(dimensions=(5, 5, 5))
large = pv.ImageData(dimensions=(10, 10, 10))
print(small.n_points)
print(large.n_points)
print(small.probe(large).n_points)  # gives different result
print(small.sample(large).n_points)
print(small.interpolate(large).n_points)
```


This  gives

```txt
125
1000
1000
125
125
```

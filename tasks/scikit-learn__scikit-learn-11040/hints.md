Hello, I would like to take this as my first issue. 
Thank you.
@amueller 
I added a simple check for float inputs for  n_neighbors in order to throw ValueError if that's the case.
@urvang96 Did say he was working on it first @Alfo5123  ..

@amueller I think there is a lot of other estimators and Python functions in general where dtype isn't explicitely checked and wrong dtype just raises an exception later on.

Take for instance,
```py
import numpy as np

x = np.array([1])
np.sum(x, axis=1.)
```
which produces,
```py
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "lib/python3.6/site-packages/numpy/core/fromnumeric.py", line 1882, in sum
    out=out, **kwargs)
  File "lib/python3.6/site-packages/numpy/core/_methods.py", line 32, in _sum
    return umr_sum(a, axis, dtype, out, keepdims)
TypeError: 'float' object cannot be interpreted as an integer
```
so pretty much the same exception as in the original post, with no indications of what is wrong exactly. Here it's straightforward because we only provided one parameter, but the same is true for more complex constructions. 

So I'm not sure that starting to enforce int/float dtype of parameters, estimator by estimator is a solution here. In general don't think there is a need to do more parameter validation than what is done e.g. in numpy or pandas. If we want to do it, some generic type validation based on annotaitons (e.g. https://github.com/agronholm/typeguard) might be easier but also require more maintenance time and probably harder to implement while Python 2.7 is supported. 

pandas also doesn't enforce it explicitely BTW,
```python
pd.DataFrame([{'a': 1, 'b': 2}]).sum(axis=0.)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "lib/python3.6/site-packages/pandas/core/generic.py", line 7295, in stat_func
    numeric_only=numeric_only, min_count=min_count)
  File "lib/python3.6/site-packages/pandas/core/frame.py", line 5695, in _reduce
    axis = self._get_axis_number(axis)
  File "lib/python3.6/site-packages/pandas/core/generic.py", line 357, in _get_axis_number
    .format(axis, type(self)))
ValueError: No axis named 0.0 for object type <class 'pandas.core.frame.DataFrame'>
```
@Alfo5123 I claimed the issue first and I was working on it. This is not how the community works.
@urvang96 Yes, I understand, my bad. Sorry for the inconvenient.  I won't continue on it. 
@Alfo5123  Thank You. Are to going to close the existing PR?
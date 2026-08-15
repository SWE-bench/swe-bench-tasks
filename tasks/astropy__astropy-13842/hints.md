Ouch! Reproduce this. Also
```
table2['new'] is table1['new']
# True
```
so the problem seems to be that the tables hold the same `Quantity` instead of different instances that share the data.
Note that it is not specific to `QTable`, but just to any mixin column (and the behaviour not limited to `dict` either):
```
import numpy as np
from astropy.table import Table
from astropy.time import Time
table1 = Table({'t': Time(np.arange(50000., 50004.), format='mjd')})
table2 = Table({'new': table1['t']}, copy=False)
print(f"{table1.colnames=}, {table2.colnames=}")
# table1.colnames=['new'], table2.colnames=['new']
table3 = Table([table1['new']], names=['old'], copy=False)
print(f"{table1.colnames=}, {table2.colnames=}, {table3.colnames=}")
# table1.colnames=['new'], table2.colnames=['old'], table3.colnames=['old']
```

EDIT: actually the above is puzzling; why is `table1.colnames` still `['new']`? Checking, I see that `table1['new'] is table2['old']` holds and `table1['new'].info.name` gives 'old'...

Not completely sure how easy it is to change this behaviour -- can we could on any mixing column to allow `new_instance = cls(old_instance, copy=False)`. The relevant code is https://github.com/astropy/astropy/blob/96dde46c854cd34cf3fd4b485d1250e32a78648e/astropy/table/table.py#L1265-L1270
It may get a bit worse. After my above example:
```
table1['new'].info.parent_table is table1
# False
table1['new'].info.parent_table is table3
# True
```
Similarly, after the example on top,
```
table1['new'].info.parent_table is table2
# True
```
So, the mixin columns belong to the last table they were made part of.

Time to ping @taldcroft...
@taldcroft - I think the solution would be to have something like `Time`'s `replicate()` on all info. The implementation that would work for all astropy classes (I think) is
```
map = mixin.info._represent_as_dict()
map['copy'] = False
new_instance = mixin.info._construct_from_dict(map)
```

Something like this could become part of `col_copy` if it had a `copy` argument.
@mhvk - not good... unfortunately I'm trying to be mostly on vacation at the moment, but if you have ideas please have a go at trying an implementation.
Hmm. Maybe the logic here needs fixing:

https://github.com/astropy/astropy/blob/bcde23429a076859af856d941282f3df917b8dd4/astropy/table/groups.py#L351-L360
Mostly finished with a fix for this which makes it possible to aggregate tables that have mixin columns. In cases where the aggregation makes sense (e.g. with Quantity) it will just work. In other cases a warning only.
Thanks, @sanjayankur31, we'll look into it.
Looks like the [culprit](https://docs.python.org/3.8/whatsnew/3.8.html#changes-in-python-behavior) might be:

> Removed `__str__` implementations from builtin types bool, int, float, complex and few classes from the standard library. They now inherit `__str__()` from object. As result, defining the `__repr__()` method in the subclass of these classes will affect they string representation.

The unit test results in the build log shows issues with `DSfloat.__str__()/DSfloat.__repr__()` and `IS.__repr__()` on lines [350](https://github.com/pydicom/pydicom/blob/6d8ef0bfcec983e5f8bd8a2e359ff318fe9fcf65/pydicom/valuerep.py#L353)/353 and [520](https://github.com/pydicom/pydicom/blob/6d8ef0bfcec983e5f8bd8a2e359ff318fe9fcf65/pydicom/valuerep.py#L520) of current master.

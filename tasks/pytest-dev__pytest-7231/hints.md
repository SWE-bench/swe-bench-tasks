this is the logging default behaviour

```pycon
>>> import logging
>>> logging.error("%s" , "a", "b")
--- Logging error ---
Traceback (most recent call last):
  File "/usr/lib64/python3.7/logging/__init__.py", line 1025, in emit
    msg = self.format(record)
  File "/usr/lib64/python3.7/logging/__init__.py", line 869, in format
    return fmt.format(record)
  File "/usr/lib64/python3.7/logging/__init__.py", line 608, in format
    record.message = record.getMessage()
  File "/usr/lib64/python3.7/logging/__init__.py", line 369, in getMessage
    msg = msg % self.args
TypeError: not all arguments converted during string formatting
Call stack:
  File "<stdin>", line 1, in <module>
Message: '%s'
Arguments: ('a', 'b')
>>> 
```

so we need  a more out of band handling for logging errors
As far as I can see the ``logging.error`` is not shown if test is passed. But if test fails ``Captured stderr call`` is printed and looks like default behaviour presented by @RonnyPfannschmidt. How exactly should the expected result look like?
This is the expected result for wrong calls to logging

It should how alway fail the test 
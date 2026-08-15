Thank you for reporting.

I reproduced the same error with this mark-up:
```
.. py:class:: TestError
   :module: test
   :canonical: test.file1.TestError

.. py:method:: SomeClass.somemethod()
   :module: test.file2

   :raises .TestError: abc
```
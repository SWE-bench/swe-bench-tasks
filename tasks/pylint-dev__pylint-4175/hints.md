We are seeing the same problem. All of our automated builds failed this morning.

``` bash
$ pylint --version
pylint 2.7.0
astroid 2.5
Python 3.7.7 (tags/v3.7.7:d7c567b08f, Mar 10 2020, 10:41:24) [MSC v.1900 64 bit (AMD64)]
```

**Workaround**

Reverting back to pylint 2.6.2.


My projects pass if I disable `--jobs=N` in my CI/CD (for projects with `min_similarity_lines` greater than the default).

This suggests that the `min-similarity-lines`/`min_similarity_lines` option isn't being passed to sub-workers by the `check_parallel` code-path.

As an aside, when I last did a profile of multi-job vs single-job runs, there was no wall-clock gain, but much higher CPU use (aka cost), so I would advice *not* using `--jobs=>2`.
We have circumvented the problem by excluding R0801 in the "disable" setting of the pylintrc file. We needed to specify the issue by number - specifying it by name did not work.

We run with jobs=4, BTW.
I'm not sure if this is related, but when running pylint 2.7.1 with --jobs=0, pylint reports duplicate lines, but in the summary and final score, duplicate lines are not reported. For example:
```
pylint --jobs=0 --reports=y test_duplicate.py test_duplicate_2.py 
************* Module test_duplicate
test_duplicate.py:1:0: R0801: Similar lines in 2 files
==test_duplicate:1
==test_duplicate_2:1
for i in range(10):
    print(i)
    print(i+1)
    print(i+2)
    print(i+3) (duplicate-code)


Report
======
10 statements analysed.

Statistics by type
------------------

+---------+-------+-----------+-----------+------------+---------+
|type     |number |old number |difference |%documented |%badname |
+=========+=======+===========+===========+============+=========+
|module   |2      |NC         |NC         |100.00      |0.00     |
+---------+-------+-----------+-----------+------------+---------+
|class    |0      |NC         |NC         |0           |0        |
+---------+-------+-----------+-----------+------------+---------+
|method   |0      |NC         |NC         |0           |0        |
+---------+-------+-----------+-----------+------------+---------+
|function |0      |NC         |NC         |0           |0        |
+---------+-------+-----------+-----------+------------+---------+



Raw metrics
-----------

+----------+-------+------+---------+-----------+
|type      |number |%     |previous |difference |
+==========+=======+======+=========+===========+
|code      |14     |87.50 |NC       |NC         |
+----------+-------+------+---------+-----------+
|docstring |2      |12.50 |NC       |NC         |
+----------+-------+------+---------+-----------+
|comment   |0      |0.00  |NC       |NC         |
+----------+-------+------+---------+-----------+
|empty     |0      |0.00  |NC       |NC         |
+----------+-------+------+---------+-----------+



Duplication
-----------

+-------------------------+------+---------+-----------+
|                         |now   |previous |difference |
+=========================+======+=========+===========+
|nb duplicated lines      |0     |NC       |NC         |
+-------------------------+------+---------+-----------+
|percent duplicated lines |0.000 |NC       |NC         |
+-------------------------+------+---------+-----------+



Messages by category
--------------------

+-----------+-------+---------+-----------+
|type       |number |previous |difference |
+===========+=======+=========+===========+
|convention |0      |NC       |NC         |
+-----------+-------+---------+-----------+
|refactor   |0      |NC       |NC         |
+-----------+-------+---------+-----------+
|warning    |0      |NC       |NC         |
+-----------+-------+---------+-----------+
|error      |0      |NC       |NC         |
+-----------+-------+---------+-----------+




--------------------------------------------------------------------
Your code has been rated at 10.00/10 (previous run: 10.00/10, +0.00)
```
It looks like it's due to:
```
@classmethod
def reduce_map_data(cls, linter, data):
    """Reduces and recombines data into a format that we can report on

    The partner function of get_map_data()"""
    recombined = SimilarChecker(linter)
    recombined.open()
    Similar.combine_mapreduce_data(recombined, linesets_collection=data)
    recombined.close()
```

the `SimilarChecker` instance created gets default values, not values from config. I double checked by trying to fix it:

```--- a/pylint/checkers/similar.py
+++ b/pylint/checkers/similar.py
@@ -428,6 +428,8 @@ class SimilarChecker(BaseChecker, Similar, MapReduceMixin):
 
         The partner function of get_map_data()"""
         recombined = SimilarChecker(linter)
+        checker = [c for c in linter.get_checkers() if c.name == cls.name][0]
+        recombined.min_lines = checker.min_lines
         recombined.open()
         Similar.combine_mapreduce_data(recombined, linesets_collection=data)
         recombined.close()
```

by simply copying the `min_lines` attribute from the "root" checker in the `recombined` checker. I bet this is not the proper way to do it, but I'm not familiar with pylint codebase.


We are seeing the same problem. All of our automated builds failed this morning.

``` bash
$ pylint --version
pylint 2.7.0
astroid 2.5
Python 3.7.7 (tags/v3.7.7:d7c567b08f, Mar 10 2020, 10:41:24) [MSC v.1900 64 bit (AMD64)]
```

**Workaround**

Reverting back to pylint 2.6.2.


My projects pass if I disable `--jobs=N` in my CI/CD (for projects with `min_similarity_lines` greater than the default).

This suggests that the `min-similarity-lines`/`min_similarity_lines` option isn't being passed to sub-workers by the `check_parallel` code-path.

As an aside, when I last did a profile of multi-job vs single-job runs, there was no wall-clock gain, but much higher CPU use (aka cost), so I would advice *not* using `--jobs=>2`.
We have circumvented the problem by excluding R0801 in the "disable" setting of the pylintrc file. We needed to specify the issue by number - specifying it by name did not work.

We run with jobs=4, BTW.
I'm not sure if this is related, but when running pylint 2.7.1 with --jobs=0, pylint reports duplicate lines, but in the summary and final score, duplicate lines are not reported. For example:
```
pylint --jobs=0 --reports=y test_duplicate.py test_duplicate_2.py 
************* Module test_duplicate
test_duplicate.py:1:0: R0801: Similar lines in 2 files
==test_duplicate:1
==test_duplicate_2:1
for i in range(10):
    print(i)
    print(i+1)
    print(i+2)
    print(i+3) (duplicate-code)


Report
======
10 statements analysed.

Statistics by type
------------------

+---------+-------+-----------+-----------+------------+---------+
|type     |number |old number |difference |%documented |%badname |
+=========+=======+===========+===========+============+=========+
|module   |2      |NC         |NC         |100.00      |0.00     |
+---------+-------+-----------+-----------+------------+---------+
|class    |0      |NC         |NC         |0           |0        |
+---------+-------+-----------+-----------+------------+---------+
|method   |0      |NC         |NC         |0           |0        |
+---------+-------+-----------+-----------+------------+---------+
|function |0      |NC         |NC         |0           |0        |
+---------+-------+-----------+-----------+------------+---------+



Raw metrics
-----------

+----------+-------+------+---------+-----------+
|type      |number |%     |previous |difference |
+==========+=======+======+=========+===========+
|code      |14     |87.50 |NC       |NC         |
+----------+-------+------+---------+-----------+
|docstring |2      |12.50 |NC       |NC         |
+----------+-------+------+---------+-----------+
|comment   |0      |0.00  |NC       |NC         |
+----------+-------+------+---------+-----------+
|empty     |0      |0.00  |NC       |NC         |
+----------+-------+------+---------+-----------+



Duplication
-----------

+-------------------------+------+---------+-----------+
|                         |now   |previous |difference |
+=========================+======+=========+===========+
|nb duplicated lines      |0     |NC       |NC         |
+-------------------------+------+---------+-----------+
|percent duplicated lines |0.000 |NC       |NC         |
+-------------------------+------+---------+-----------+



Messages by category
--------------------

+-----------+-------+---------+-----------+
|type       |number |previous |difference |
+===========+=======+=========+===========+
|convention |0      |NC       |NC         |
+-----------+-------+---------+-----------+
|refactor   |0      |NC       |NC         |
+-----------+-------+---------+-----------+
|warning    |0      |NC       |NC         |
+-----------+-------+---------+-----------+
|error      |0      |NC       |NC         |
+-----------+-------+---------+-----------+




--------------------------------------------------------------------
Your code has been rated at 10.00/10 (previous run: 10.00/10, +0.00)
```
It looks like it's due to:
```
@classmethod
def reduce_map_data(cls, linter, data):
    """Reduces and recombines data into a format that we can report on

    The partner function of get_map_data()"""
    recombined = SimilarChecker(linter)
    recombined.open()
    Similar.combine_mapreduce_data(recombined, linesets_collection=data)
    recombined.close()
```

the `SimilarChecker` instance created gets default values, not values from config. I double checked by trying to fix it:

```--- a/pylint/checkers/similar.py
+++ b/pylint/checkers/similar.py
@@ -428,6 +428,8 @@ class SimilarChecker(BaseChecker, Similar, MapReduceMixin):
 
         The partner function of get_map_data()"""
         recombined = SimilarChecker(linter)
+        checker = [c for c in linter.get_checkers() if c.name == cls.name][0]
+        recombined.min_lines = checker.min_lines
         recombined.open()
         Similar.combine_mapreduce_data(recombined, linesets_collection=data)
         recombined.close()
```

by simply copying the `min_lines` attribute from the "root" checker in the `recombined` checker. I bet this is not the proper way to do it, but I'm not familiar with pylint codebase.


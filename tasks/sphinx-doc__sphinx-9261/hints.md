This is a rather insidious warning because it points the developer to the derived class as the root cause of the problem, but there is no obvious correlation between the code of the derived class and the actual cause of the problem. This is further exacerbated when the derived class is in a different project or library from the base class, because then the developer needs to review the contents of the full inheritance stack. However, even after reviewing the code for the base class (which may or may not be the direct parent class of the one exposing the error) there is no obvious correlation between the warning and the code because the doc strings on the base class(es) are defined and correctly formatted, and Sphinx does not complain when generating the docs for the base class. 

After much ad-hoc testing I was able to deduce that simply adding a doc string to the constructor on the derived class was sufficient to circumvent the error, but when working on a large number of Python projects and sharing those projects across many developers, problems like this are hard to avoid in practice.

My team manages dozens of Python projects, and are trying to build docs for all without having any warnings produced, so we've opted to disable the combined auto content flag to avoid these superfluous warnings. However, this is just a hack/workaround to get us by for now. I hope someone can investigate the root cause of this problem and fix it so that docs for derived classes can be generated without warnings. 
I think what you want is `autodoc_inherit_docstrings = False`, right? There are no way to disable warnings during processing docstrings in superclasses.
Disabling inherited doc strings is not the solution for this bug. The doc strings can and should be inheritable here. 

The problem is that one of the pre-processing steps involved with the auto content logic is trying to combine doc strings from the class and constructor of the base class as well as the derived class, and not aligning the formatting between them.
To be clear, this code snippet produces warnings:

```
class MyBase:
    """Base class docstring"""

    def __init__(self, fubar):
        """
        Args:
            fubar (str):
                parameter description here
        """
class MyDerived(MyBase):
    def __init__(self):
        pass
```

Where as this code snippet does not:


```
class MyBase:
    """Base class docstring"""

    def __init__(self, fubar):
        """
        Args:
            fubar (str):
                parameter description here
        """
class MyDerived(MyBase):
    def __init__(self):
        """testing"""
        pass
```

Both of these examples are valid Python class definitions, with valid doc strings. Both the inherited docstring functionality AND the auto content combining logic should work in both situations.
Thank you for your explanation. I misunderstood the problem!
Internally, the example is expanded to the following code (without napoleon extension):

```
.. py:class:: MyBase(fubar)
   :module: example

   Base class docstring

   :param fubar: parameter description here
   :type fubar: str


.. py:class:: MyDerived()
   :module: example

   Args:
   fubar (str):
       parameter description here
```

The second and following lines of the inherited method not having docstring is unindented. This is unexpected behavior and it's a bug.
+1

@shimizukawa,@martinpengellyphillips you may try my fork with this feature.
Install [sphinx](https://github.com/hypnocat/sphinx), and add to conf.py
autodoc_dumb_docstring = True
then rebuild docs. Feel free to msg me.

Another alternative that would be nice and might work easily is to allow the user to specify the value of an argument instead of the entire signature.
- Unspecified arguments would be parsed by sphinx as usually.
- Only the specified arguments would be annotated differently.
- Omitting `:annotation:` would remove `myarg` from the signature so that it didn't show up at all as an interesting for secret optional args.
- Specifying blank `:annotation:` would omit the default altogether but the keyword argument would still show up, just with no default value.
- If `myarg` is not in the list of arguments parsed from the signature, then a warning is raised and the directive does nothing.
- Markup roles like `:class:`, `:data:`, etc. can be used to link to the specified default.
- If `myarg` is not a keyword argument, then should it warn or should it specify the default in defiance of all logic? probably warn.

For example, given the following `mymodule.py` file:

```
"""a module with special treatment of arguments"""

DEFAULT = "a very long value that I don't want to display in my function, class and method signatures"
"""a description of the default"""

def myfunc(args, myarg=DEFAULT, kwargs=None):
    """
    a function with an ugly default arg value

    :param args: some arguments
    :param myarg: a keyword arg with a default specified by a module constant
    :param kwargs: some keyword arguments
    """
    pass

class MyClass():
    """a class with an ugly default arg value in its constructor"""
    def __init__(self, args, myarg=DEFAULT, kwargs=None):
        pass
    def mymeth(self, args, myarg=DEFAULT, kwargs=None):
        """a method with an ugly default arg value"""
        pass
```

use `mymodule.rst` file with the following:

```
.. automodule:: mymodule

.. autodata:: DEFAULT
   :annotation: a default value

The value of ``myarg`` in this function is replaced by :data:`~mymodule.DEFAULT`

.. autofunction:: myfunc
   .. argument:: myarg
      :annotation: :data:`~mymodule.DEFAULT`

The value of ``myarg`` in this class constructor is not shown

.. autoClass:: MyClass
   :members:
   .. argument:: myarg
      :annotation:

The value of ``myarg`` in this class method is hidden

.. automethod:: MyClass.mymeth
   .. argument:: myarg
```

would output the following:

> mymodule
> a module with special treatment of arguments
> 
> mymodule.DEFAULT = 'a default value'
> a description of the default
> 
> The value of `myarg` in this function is replaced by :data:`~mymodule.DEFAULT`
> 
> mymodule.myfunc(args, myarg=**DEFAULT**, kwargs=None)
> a function with an ugly default arg value
> 
> **Parameters**
> - args - some arguments
> - myarg - a keyword arg with a default specified by a module constant
> - kwargs - some keyword arguments
> 
> The value of `myarg` in this class constructor is not shown
> 
> mymodule.MyClass(args, myarg=, kwargs=None)
> a class with an ugly default arg value in its constructor
> 
> The value of `myarg` in this class method is hidden
> 
> mymodule.MyClass.mymeth(args, kwargs=None)
> a method with an ugly default arg value

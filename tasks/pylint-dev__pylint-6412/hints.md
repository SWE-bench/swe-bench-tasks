This sounds good but note that we'd need to support the old style until we move the plugins to the new format. 
Agreed
I'm going to take this on as a next step towards `3.0`. I have been experimenting with this and it seems like this will be fairly easy to implement. The biggest difficulty comes from deprecating this in a clear way and giving plugins enough time to adapt.

It should be much less of a hassle (for us at least) than the `argparse` migration but will be crucial to put in `3.0`.

As a first step I have been working on https://github.com/DanielNoord/pylint/pull/129 which supports this for the first two interfaces.


Note that the system we currently use seems to be based on a rejected PEP from 2001, see: https://peps.python.org/pep-0245/
Does anybody have any good ideas how to handle the deprecation of these `Interface` classes?
Because we do:
```python
class MyChecker(BaseChecker):
    __implements__ = IAstroidChecker
```
we don't hit the ``__init__`` of ``IAstroidChecker`` so that doesn't really work. I'm not sure what the best approach would be here.
Can we check if ``__implements__`` is defined inside ``BaseChecker``'s constructor and warn for each interface if that's the case ?
> Can we check if `__implements__` is defined inside `BaseChecker`'s constructor and warn for each interface if that's the case ?

The issue with that is that we don't really check all uses of `IAstroidChecker`. This would not raise a warning:
```python
class MyBaseChecker:
    __implements__ = IAstroidChecker

# All other methods needed to mimic BaseChecker
def add_message():
    ...
```

Thus, would that approach be enough?
Ha yes, I supposed everything would inherit from BaseChecker. We can also check that our checkers are instances of BaseChecker when we loop on them in the PyLinter then ?
Yeah, but then we still don't really check the imports. The difficult comes from the fact that the normal usage of these classes is to import them but not instantiate them. Thus, we can't warn during ``__init__`` and have no good way (that I know of) of checking whether they are imported/used. 
The interface class are not instanced directly but they have no use apart from being used as a semantic interface in a checker (that I know off). And indeed they have no behavior inside them so I don't see how they could be used any other way than semantically. I think not warning for import is okay.
Okay so we would want a warning in:
1. The ``__init__`` of ``BaseChecker`` to check for a ``__implements__`` member
2. The ``__init__`` of all interfaces (just to be sure)
3. All current calls to ``__implements__``

Right?
Sounds right !
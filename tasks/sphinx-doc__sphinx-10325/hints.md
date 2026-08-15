+1: Acceptable change.
>A class inherits from multiple other classes. I want to document members from some of the base classes but ignore some of the base classes

For example, there is a class that inherits multiple base classes:
```
class MyClass(Parent1, Parent2, Parent3, ...):
    pass
```
and

```
.. autoclass:: example.MyClass
   :inherited-members: Parent2
```

How should the new `:inherited-members:` work? Do you mean that the member of Parent2 are ignored and the Parent1's and Parent3's are documented? And how about the methods of the super classes of `Parent1`?

Note: The current behavior is ignoring Parent2, Parent3, and the super classes of them (including Parent1's also). In python words, the classes after `Parent2` in MRO list are all ignored.
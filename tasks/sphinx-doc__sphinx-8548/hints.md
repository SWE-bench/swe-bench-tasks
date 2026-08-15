_From [mitar](https://bitbucket.org/mitar) on 2012-01-07 18:21:47+00:00_

Also {{{find_attr_doc}}} seems to not find inherited attributes?

_From [mitar](https://bitbucket.org/mitar) on 2012-01-07 20:04:22+00:00_

The problem is also that parser for attributes' doc strings parses only one module. It should also parses modules of all parent classes and combine everything.

_From Jon Waltman on 2012-11-30 15:14:18+00:00_

Issue #1048 was marked as a duplicate of this issue.

I'm currently getting bit by this issue in 1.2.3.  https://github.com/sphinx-doc/sphinx/issues/2233 is preventing me from working with `1.3.x`.  Is there a workaround you might recommend?  

Is there any hope of getting this fixed, or a workaround? As mentioned in  #1048 even using autoattribute does not work. 

I'm also running into this.  For now I'm manually duplicating docstrings, but it would be nice if `:inherited-members:` worked.

I'm not familiar with the code base at all, but if anyone's willing to point me in a direction I can try to write a fix.

Any news on this feature / bugfix ?
I am also awaiting a fix for this, fwiw
I don't understand this problem. Could anyone make an example to me? I'll try to fix it if possible.
@tk0miya Here's a very simple example project: [sphinx-example.tar.gz](https://github.com/sphinx-doc/sphinx/files/2753140/sphinx-example.tar.gz).


```python
class Base:
    """The base class."""

    #: A base attribute.
    ham = True

    def eggs(self):
        """A base method."""


class Inherited(Base):
    """The subclass."""

    #: A local attribute.
    foo = 3

    def bar(self):
        """A local method."""
```

```rst
.. autoclass:: example.Inherited
    :inherited-members:
```

The `Base.ham` attribute is not present in the docs for `Inherited`. However, the `Base.eggs` inherited method is displayed.
In my case ham is an instance attribute and I want it to be auto-documented but it is not working. 

```
class Base:
    """The base class."""

    def __init__(self):
        #: A base attribute.
        self.ham = True

    def eggs(self):
        """A base method."""
```


I am not sure it is even technically possible for Sphinx to auto-document `self.ham`. As I understood Sphinx finds attributes by code inspection, not actually instantiating the class.  And to detect the ham instance attribute it seems to me you need to instantiate the Base class.
It seems latest Sphinx (2.0.1) is able to process inherited attributes. On the other hand, inherited-instance attributes are not supported yet (filed as #6415 now).
So I think this issue has been resolved now.

I'm closing this. Please let me know if you're still in problem.

Thanks,
@tk0miya I just tried the example I posted earlier with Sphinx 2.1.0 and this issue still occurs. https://github.com/sphinx-doc/sphinx/issues/741#issuecomment-453832459

#6415 and @Dmitrii-I's comment is different, but possibly related.
Thank you for comment. my bad. Just reopened. I might give `:undoc-members:` option on testing...

Inside autodoc, the comment based docstring is strongly coupled with its class. So autodoc considers the docstring for `Base.ham` is not related with `Inherited.ham`. As a result, `Inherited.ham` is detected undocumented variable.

I'll try to fix this again.
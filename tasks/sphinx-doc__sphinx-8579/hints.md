Hi,
Thanks for the report! I can reproduce the issue.
I’ll be looking into fixing it later today.
I understand what is wrong:

Linkcheck organizes the urls to checks in a `PriorityQueue`. The items are tuples `(priority, url, docname, lineno)`. For some links, the `get_node_line()` returns `None`, I’m guessing the line information is not available on that node.
A tuple where the `lineno` is `None` is not comparable with `tuples` that have an integer `lineno` (`None` and `int` aren’t comparable), and `PriorityQueue` items must be comparable (see https://bugs.python.org/issue31145).

That issue only manifests when a link has no `lineno` and a document contains two links to the same URL. In [Weblate README.rst](https://raw.githubusercontent.com/WeblateOrg/weblate/master/README.rst):

```sphinx
.. image:: https://s.weblate.org/cdn/Logo-Darktext-borders.png
   :alt: Weblate
   :target: https://weblate.org/
```
And:
```sphinx
Install it, or use the Hosted Weblate service at `weblate.org`_.

.. _weblate.org: https://weblate.org/
```

I have a minimal regression test and will investigate how the line number is acquired tomorrow. If that’s reasonable, I think it would be more helpful to have the original line number where the URL appeared. If it is too big of a change for a fix release, I’ll probably end-up wrapping the data in a class that handles the comparison between no line number information and a line number information (and its variants).
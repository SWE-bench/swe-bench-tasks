Are you sure the old links are broken? While the permalink is indeed using a new ID generation scheme, the old ID should still be attached to the declaration (using ``<span id="theOldID"></span>``).
Yes, I changed the style of node_ids in #7236. Therefore, the main hyperlink anchor will be changed in the next release. But old-styled node_ids are still available. So old hyperlinks are still working.

There are some reasons why I changed them. First is that their naming is very simple and getting conflicted often (refs: #6903). Second is the rule of naming is against docutils specification. Last is that it allows sharing one node_ids to multiple names. For example, it helps to represent `io.StringIO` and `_io.StringIO` are the same (or they have the same ID).

To improve both python domain and autodoc, we have to change the structure of the domain and the rule of naming IDs. I don't know the change is harmful. But it is needed to improve Sphinx, I believe.
Thanks for the quick responses!

> Are you sure the old links are broken?

I thought so, but links from external sites seem to be *not yet* broken.

However, it looks like they will be broken at some point in the future, according to this comment:

https://github.com/sphinx-doc/sphinx/blob/f85b870ad59f39c8637160a4cd4d865ce1e1628e/sphinx/domains/python.py#L367-L370

Whether that happens sooner or later, it will be quite bad.

But that's not actually the situation where I found the problem. The ID change is breaking my Sphinx extension `nbsphinx` because the code assumed that underscores are not changed to dashes:

https://github.com/spatialaudio/nbsphinx/blob/5be6da7b212e0cfed34ebd7da0ede5501549571d/src/nbsphinx.py#L1446-L1467

This causes a build warning (and a missing link) when running Sphinx.
You can reproduce this by building the `nbsphinx` docs, see https://nbsphinx.readthedocs.io/en/0.5.1/contributing.html.

I could of course change the implementation of `nbsphinx` (depending on the Sphinx version), but that would still break all the API links my users have made in their notebooks!

And it would break them depending on which Sphinx version they are using, wouldn't that be horrible?

> First is that their naming is very simple and getting conflicted often (refs: #6903).

How does changing `#example_python_function` to `#example-python-function` help in this case?

> Second is the rule of naming is against docutils specification.

Because underscores are not allowed?

I think it would be worth violating the specification for that.
I don't see any negative consequences to this.
And it has worked fine for many years.

Also, having dots and underscores in link to API docs just looks so much more sensible!

Here's an example: https://sfs-python.readthedocs.io/en/0.5.0/sfs.fd.source.html#sfs.fd.source.point_velocity

The link contains the correct Python function name: `#sfs.fd.source.point_velocity`.

When the ID is changed, this becomes: `#sfs-fd-source-point-velocity`, which doesn't really make any sense anymore.

> Last is that it allows sharing one node_ids to multiple names. For example, it helps to represent `io.StringIO` and `_io.StringIO` are the same (or they have the same ID).

I don't understand. Are `io` and `_io` not different names in Python?

And what does that have to do with changing underscores to dashes?
>>First is that their naming is very simple and getting conflicted often (refs: #6903).
>
>How does changing #example_python_function to #example-python-function help in this case?

No, this change is not only replacing underscores by hyphens. New ID Generator tries to generate node_id by following steps; 1) Generate node_id by the given string. But generated one is already used in the document,  2) Generate node_id by sequence number like `id0`.

It means the node_id is not guess-able by its name. Indeed, it would be almost working fine if we use hyphens and dots for the ID generation. But it will be sometimes broken.

>>Second is the rule of naming is against docutils specification.
>
>Because underscores are not allowed?
>
>I think it would be worth violating the specification for that.
>I don't see any negative consequences to this.
>And it has worked fine for many years.

Yes, docutils' spec does not allow to use hyphens and dots in node_id.

I know the current rule for node_id generation is not so wrong. But it surely contains problems. Have you ever try to use invalid characters to the signature? How about multibyte characters?

For example, this is an attacking code for the ID generator:
```
.. py:function:: "><script>alert('hello sphinx')</script>
```

I know this is a very mean example and not related to hyphens' problem directly. But our code and docutils do not expect to pass malicious characters as a node_id. I suppose dots and hyphens may not harm our code. But we need to investigate all of our code to prove the safety.

>>Last is that it allows sharing one node_ids to multiple names. For example, it helps to represent io.StringIO and _io.StringIO are the same (or they have the same ID).
>
>I don't understand. Are io and _io not different names in Python?
>
>And what does that have to do with changing underscores to dashes?

Indeed, `io` and `_io` are different names in python interpreter. But please read the python-doc. The latter one is not documented in it. We have some issues to document a python object as "public name" instead of "canonical name". see #4065. It is one of them. This feature is not implemented yet. But I'll do that in the (nearly) future. It tells us the real name of the living object does not match the documentation of it.

As you know, it is not related to hyphens problem. It also conflicts with the hyperlinks which human builds manually. It's no longer guess-able. If we'll keep using dots and hyphens for node_id, the cross-reference feature is needed to create references for nbsphinx, I think.
> > How does changing #example_python_function to #example-python-function help in this case?
> 
> No, this change is not only replacing underscores by hyphens. New ID Generator tries to generate node_id by following steps; 1) Generate node_id by the given string. But generated one is already used in the document, 2) Generate node_id by sequence number like `id0`.

OK, that sounds great. So what about doing that, but also allow underscores (`_`) and dots (`.`)?

> I know the current rule for node_id generation is not so wrong. But it surely contains problems. Have you ever try to use invalid characters to the signature? How about multibyte characters?

OK, I understand that it might be problematic to allow arbitrary characters/code points.

But what about just adding `_` and `.` to the allowed characters?

> For example, this is an attacking code for the ID generator:
> 
> ```
> .. py:function:: "><script>alert('hello sphinx')</script>
> ```

I'm not sure if that's really a problematic case, because the attack would have to come from the document content itself. I'm not a security specialist, so I'm probably wrong.

Anyway, I'm not suggesting to allow arbitrary characters.

`_` and `.` should be safe from a security standpoint, right?

> > > Last is that it allows sharing one node_ids to multiple names. For example, it helps to represent io.StringIO and _io.StringIO are the same (or they have the same ID).
> > 
> > I don't understand. Are io and _io not different names in Python?
> > And what does that have to do with changing underscores to dashes?
> 
> Indeed, `io` and `_io` are different names in python interpreter. But please read the python-doc.

I can see that those are not the same name.

What IDs are those supposed to get?

IMHO it would make perfect sense to give them the IDs `#io` and `#_io`, respectively, wouldn't it?

> The latter one is not documented in it. We have some issues to document a python object as "public name" instead of "canonical name". see #4065. It is one of them. This feature is not implemented yet. But I'll do that in the (nearly) future. It tells us the real name of the living object does not match the documentation of it.

I don't really understand any of this, but would it make a difference if underscores (`_`) were allowed in IDs?

> As you know, it is not related to hyphens problem. It also conflicts with the hyperlinks which human builds manually. It's no longer guess-able. If we'll keep using dots and hyphens for node_id, the cross-reference feature is needed to create references for nbsphinx, I think.

I don't understand.
Do you mean I should create my own custom IDs in `nbsphinx` and overwrite the ones generated by Sphinx?
I guess I will have to do something like that if you are not modifying the way IDs are generated by Sphinx.
I could probably do something similar to https://github.com/spatialaudio/nbsphinx/blob/559fc4e82bc9e2123e546e67b8032643c87cfaf6/src/nbsphinx.py#L1384-L1407.

I *do* understand that IDs should be unique per HTML page, and I don't mind if the second (and third etc.) duplicate is re-written to `#id0` etc., but I would really like to have readable and understandable IDs (for Python API links) for the case that there are no duplicate IDs (and for the first one even if there are duplicates). And (probably more importantly?) I would like to avoid too much breakage in the projects of `nbsphinx` users.
>OK, I understand that it might be problematic to allow arbitrary characters/code points.
>But what about just adding _ and . to the allowed characters?

Surely, I don't think `_` and `.` will not cause the problem, as you said. But are you satisfied if I agree to support `_` and `.`? How about capital characters too. How about the latin-1 characters? If you need to change the charset, we need to define the allowed charset for node IDs (and confirm they are safe as possible). Is it okay to support only `_` and `.`?

>I don't understand.
>Do you mean I should create my own custom IDs in nbsphinx and overwrite the ones generated by Sphinx?
>I guess I will have to do something like that if you are not modifying the way IDs are generated by Sphinx.

So far, a node_id of a python object had been the same as its name. Since Sphinx-3.0, it will be changed. The new implementation is almost the same as other domains do for the cross-references.

To realize the new cross-reference feature, we use a "reference name" and location info. A reference name equals the name of the object. For example, `io`, `io.StringIO`, `int`, `MyClass`, `MyClass.meth` and so on. A location info is a pair of a docname and a node ID.

On building a document, the python domain goes the following steps:

1. Collects definitions of python objects written by their directives (ex. `py:function::`, `py:class::`, etc.) and creates a mapping from the reference-names to the location info.
2. Every time find cross-reference roles, look up the location info from the mapping using the reference name of the role. For example, when a role ```:py:mod:`io` ``` found, the python domain look up the location info by the reference name; `io`. If succeeded, the role is converted to a reference to the specified node in the document.
3. Renders the references to the output in the arbitrary format.

This means generating URL manually is not recommended. The node_id is not guess-able because it is sometimes auto-generated (ex. `id0`). I still don't think about how to implement `io` and `_io` case. But it will obey the structure above.

Note: docutils spec says node_id should be starts with a letter `[a-z]`. So `_io` will be converted into `io` (if not already registered).
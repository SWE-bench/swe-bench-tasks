Changing to `Ellipsis`:

```python
    async def trio_main(
        self,
        async_fn: typing.Callable[Ellipsis, typing.Awaitable[None]],
        args: typing.Tuple[object, Ellipsis],
    ) -> None:
```

Still results in the same output, even still with `..`.

```
/home/altendky/repos/preqtrio/qtrio/_core.py:docstring of qtrio.Runner.trio_main:: WARNING: py:class reference target not found: ..
/home/altendky/repos/preqtrio/qtrio/_core.py:docstring of qtrio.Runner.trio_main:: WARNING: py:class reference target not found: ..
```

Other substitutes like `int` eliminate the warning as you might expect.
I don't know if this will provide any useful context but `qtrio._pytest.host` uses `@typing.overload` resulting in hints in the signature per #7785.  It also doesn't trigger the 'not found' reported here nor does the ellipsis turn into `[..]`.  

![image](https://user-images.githubusercontent.com/543719/90302255-ece09280-de72-11ea-8e64-5218a0928060.png)

So I tried `autodoc_typehints = 'signature'` and the warning went away.  Notice how while the square brackets are still added, there are three dots in the ellipsis unlike above.

![image](https://user-images.githubusercontent.com/543719/90302337-827c2200-de73-11ea-9708-f7defda6ce1b.png)

Just in case this offers any insight...  This is the result of just messing around so nothing has been committed.  If valuable I can provide it of course.
Suggesting a workaround until the issue is fixed. In your `conf.py`:
```py
from docutils.nodes import Text
from sphinx.ext.intersphinx import missing_reference


def setup(app):
    app.connect("missing-reference", __sphinx_issue_8127)


def __sphinx_issue_8127(app, env, node, contnode):
    reftarget = node.get("reftarget", None)
    if reftarget == "..":
        node["reftype"] = "data"
        node["reftarget"] = "Ellipsis"
        text_node = next(iter(contnode.traverse(lambda n: n.tagname == "#text")))
        replacement_node = Text("...", "")
        if text_node.parent is not None:
            text_node.parent.replace(text_node, replacement_node)
        else:  # e.g. happens in rtype fields
            contnode = replacement_node
        return missing_reference(app, env, node, contnode)
```
This will rewrite all the `..` to a `...` with a ref ``:py:data:`Ellipsis` ``.
I reproduced the error with the following mark-up:

```
.. py:function:: foo(fn)

   :param fn: blah
   :type fn: typing.Callable[..., typing.Awaitable[None]]
```
Unfortunately, the real name of `types.TracebackType` is `traceback`.

```
$ python
Python 3.9.1 (default, Dec 18 2020, 00:18:40)
[Clang 11.0.3 (clang-1103.0.32.59)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> from types import TracebackType
>>> TracebackType
<class 'traceback'>
>>> TracebackType.__module__
'builtins'
```

As a result, `ExceptionInfo.from_exc_info` was rendered as following (internally):
```
   .. py:method:: ExceptionInfo.from_exc_info(exc_info: Tuple[Type[example.E], example.E, traceback], exprinfo: Optional[str] = None) -> example.ExceptionInfo[example.E]
      :module: example
      :classmethod:
```

After that, the "traceback" name confuses Sphinx.
Ah the `traceback` makes sense now, thanks.

So I guess the problem is that the `builtins` gets elided + has lesser priority than the property. The second part makes sense, but for the first part, is it viable to keep the `builtins`, but just not display it?
Would you like to see `builtins.int` or `builtins.str`? Of course, it's possible technically. But nobody wants to show it, I think.
I mean that it would become `builtins.traceback` in the sphinx code but rendered in HTML as just `traceback`. But that's just a thought, I didn't try to check how viable this is. Another complicating factor is that `traceback` is not actually present in the `builtins` module.

BTW, if it's rendered as

```rst
   .. py:method:: ExceptionInfo.from_exc_info(exc_info: Tuple[Type[example.E], example.E, traceback], exprinfo: Optional[str] = None) -> example.ExceptionInfo[example.E]
      :module: example
      :classmethod:
```

maybe it makes sense to just skip properties when trying to resolve *types*.
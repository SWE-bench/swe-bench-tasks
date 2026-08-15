It seems some objects are described manually via `class` directive. For example, `hondana.enums.ReadingStatus` is described as following:

```
.. currentmdoule:: hondana

(snip)

.. class:: ReadingStatus

   Specifies the current reading status for this manga
```

But autodoc generates a reference `hondana.enums.ReadingStatus` instead of `hondana.ReadingStatus` because autodoc generates document from real python objects.

To avoid such mismatches, you can use `:canonical:` option to this declaration:

```
.. currentmdoule:: hondana

(snip)

.. class:: ReadingStatus
   :canonical: hondana.enums.ReadingStatus

   Specifies the current reading status for this manga
```

This describe `ReadingStatus` class is described as `hondana.ReadingStatus` in document, and its canonical name is `hondana.enums.ReadingStatus`. This helps to resolve cross references from autodoc.
Note: Dockerfile to reproduce the warnings
```
FROM python:3.9-slim

RUN apt update; apt install -y build-essential curl git unzip vim
RUN git clone -b docs/fixup https://github.com/AbstractUmbra/Hondana
WORKDIR Hondana
RUN pip install poetry
RUN poetry install -E docs
RUN poetry run sphinx-build -a -E -n -T docs/ docs/_build
```
Wow, thank you for this, I appreciate it a lot.

Can I be a bother once more and query something else. If you have a look at this patch:

```diff
iff --git a/hondana/client.py b/hondana/client.py
index f6e8782..4d59373 100644
--- a/hondana/client.py
+++ b/hondana/client.py
@@ -89,7 +89,7 @@ from .utils import MISSING, require_authentication
 
 
 if TYPE_CHECKING:
-    import aiohttp
+    from aiohttp import ClientSession
 
     from .tags import QueryTags
     from .types import common, legacy, manga
@@ -141,7 +141,7 @@ class Client:
         username: None = ...,
         email: None = ...,
         password: None = ...,
-        session: Optional[aiohttp.ClientSession] = ...,
+        session: Optional[ClientSession] = ...,
         refresh_token: None = ...,
     ) -> None:
         ...
... truncated for brevity, but it's just more overloads being edited
```

This then generates the following error:
```
Poe => poetry run sphinx-build -a -E -n -T -W --keep-going docs/ docs/_build
Running Sphinx v4.5.0
loading intersphinx inventory from https://docs.python.org/3/objects.inv...
loading intersphinx inventory from https://docs.aiohttp.org/en/stable/objects.inv...
building [mo]: all of 0 po files
building [html]: all source files
updating environment: [new config] 5 added, 0 changed, 0 removed
reading sources... [100%] types                                                                                                                                                                                                                                                                                                                 
looking for now-outdated files... none found
pickling environment... done
checking consistency... done
preparing documents... done
writing output... [100%] types                                                                                                                                                                                                                                                                                                                  
/home/penumbra/projects/personal/hondana/hondana/client.py:docstring of hondana.client.Client:: WARNING: py:class reference target not found: ClientSession
/home/penumbra/projects/personal/hondana/hondana/client.py:docstring of hondana.client.Client:: WARNING: py:class reference target not found: ClientSession
/home/penumbra/projects/personal/hondana/hondana/client.py:docstring of hondana.client.Client:: WARNING: py:class reference target not found: ClientSession
/home/penumbra/projects/personal/hondana/hondana/client.py:docstring of hondana.client.Client:: WARNING: py:class reference target not found: ClientSession
/home/penumbra/projects/personal/hondana/hondana/client.py:docstring of hondana.client.Client:: WARNING: py:class reference target not found: ClientSession
...
```

As this is a third party dependency I cannot edit how this reference is found.
The "fix" I found was to import the whole module and use the whole path but this is not really ideal. Is there a way I can resolve this, or?

I have pushed the changes you suggested to the same branch but am still having some issues with more types. Could I bother you for some more guidance on those too?
Is there no way to add the `:canonical:` directive to `:autoclass:` objects?
I have [these definitions](https://github.com/AbstractUmbra/Hondana/blob/docs/fixup/docs/types.rst#L9-L15) and it seems sphinx does not like these paths for the `autodoc_typehints`:
![Code_J9pgTG4s9s](https://user-images.githubusercontent.com/16031716/162406350-3fbc0909-21cb-41e5-b786-fc6d8f646540.png)
I can see that they are documented just fine, but no matter what I try I cannot stop the errors in the console go away.

The file in question is [here](https://github.com/AbstractUmbra/Hondana/blob/b00b4f5cd420010890f16f4c48af8d10ac253f01/hondana/types/common.py).

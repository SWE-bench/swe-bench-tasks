So I found a work around or "proved" to myself that I didn't read the instructions completely wrong.
If I just change ``language='da'`` to ``language='en'`` in ``conf.py`` and rename ``locale/da/`` to ``locale/en/`` it works as expected. My few select changes to the translation of internal messages are show.
```
$ git clone https://github.com/jonascj/sphinx-test-locale-override.git
$ cd sphinx-test-locale-override
$ # make python venv however you like
$ pip install sphinx
$ make html
```
Open _build/html/index.html. Notice how the figure caption label is now Foobar (for testing) and the code block caption label Whatever, as expected.

![Screenshot of index.html](https://yapb.in/uTfo.png)

Of course now the rest of the internal messages are in English and I needed them in Danish. But that is also easily worked around. Just obtain a copy of the published or packaged ``locale/da/LC_MESSAGES/sphinx.po`` [1], rename it to ``locale/en/LC_MESSAGES/sphinx.po`` and change any messages wanting change. Semantically it is not pretty, since the config says it is English, but the html output will be as desired (Danish translations with a few changes).

Maybe it is related to this, I am not completely sure: https://github.com/sphinx-doc/sphinx/issues/1242

If it is not a bug, it is at least unexpected behavior . If furt,her are needed to make it work (without my workaround) the documentation should be updated to mention it [2]

[1] https://github.com/sphinx-doc/sphinx/blob/master/sphinx/locale/da/LC_MESSAGES/sphinx.po
[2] http://www.sphinx-doc.org/en/master/usage/configuration.html#confval-locale_dirs
At present, `${locale_dirs}/{language}/LC_MESSAGES/sphinx.mo` is only used if failed to look the message up from the system's message catalog.

@shimizukawa Which is correct the behavior or document? 
I'm not sure which is correct. IMO, it is better to override the system values with the intentionally provided `sphinx.mo` file.
By the way, #1246 is related.
On second thought, I believe that providing at least a way to access the percentage of translated paragraphs on the entire documentation.

```restructuredtext
.. warning::

   This document is not fully translated yet (progress: XXXXX %).
```

would be a valuable feature for Sphinx.

I would like advice on what syntax should be used for the `XXXXX` element. reST primarily provides roles for this sort of inline markup, but ``` :translation-progress:`` ```, with an empty content, sounds a bit awkward...

Maybe define a substitution `|translation-progress|` like `|today|`?

Another question is what would be ideal to get the translation progress of the current *page* (rst/md file, instead of the whole documentation). For HTML, this would be useful. One could also have ``` :page-translation-progress:`` ``` / `|page-translation-progress|`. Actually, this could be a way to alleviate the weirdness of the empty argument: `` :translation-progress:`doc` `` or `` :translation-progress:`page` ``?

With that scheme, it's feasible to include a warning in one specific page, and it can also be done at the top of every page using

```python
rst_prolog = r"""
.. warning::
   This page is not fully translated yet (progress: XXXXX %).
"""
```

although how to translate that very warning is another issue (#1260).

Yet… I wonder if this is ideal. For HTML output, one might want to put the warning in a totally different location than the top of the page, like in the sidebar. Thus, it would also make sense to have a Jinja2 variable in the context for the translation progress.

On the other hand, just such a variable does not allow use in output formats other than HTML.

I'm not quite sure how to best approach this. Any opinions from Sphinx maintainers?
I've thought about something similar some time ago and I didn't come up with a good idea to solve it. I'd love to see a warning in the page that I'm reading communicating me that's not finished and there may be some paragraphs in the original language. That will avoid lot of confusions to users.

In the official translation of the Python documentation to Spanish, we are using `potodo`[^1] to know the translation progress: https://python-docs-es.readthedocs.io/es/3.11/progress.html

Maybe `potodo` can be distributed as a sphinx extension that exposes all these values and substitutions that you mentioned. I think it could be a really good combination of existing tools. We would just need to put all the glue in between to make it user-friendly and integrated with Sphinx.

[^1]: https://pypi.org/project/potodo/
potodo is great, we also use it in python-docs-fr (for which it was originally developed), and I use it in my personal projects too. However, I think the way it works has some shortcomings if the goal is to inform the reader about what remains to be done, as opposed to the translator. potodo basically just parses the po files and prints statistics on them. In particular,

a) Suppose that nobody maintains a translation for some time. Messages keep being added and modified in the original, but the po file isn’t updated. In this case, the po file can remain 100% translated while the documentation is not, until the next run of msgmerge / sphinx-intl update.


b) It works per po file. HTML pages will be more granular than that if gettext_compact = True is set in the Sphinx config.

On the other hd, since Sphinx only relies on the presence of mo files but not po files, it cannot tell fuzzy strings from untranslated strings.

Overall, these are different approaches, I think they serve different use cases. This is why I’m trying to see if we can make Sphinx provide info about translation progress.
> I'd like to know if it would be acceptable to just delete the two lines of code above in order to let extensions know whether a node has been translated.

Seems reasonable.

A
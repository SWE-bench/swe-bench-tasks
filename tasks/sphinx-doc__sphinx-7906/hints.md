The `:noindex:` option is usually used to disable to create a cross-reference target. For example, `.. py:module::` directive goes to create a target and to switch current module (current namespace). And we give `:noindex:` option to one of `py:module:` definition to avoid conflicts.
```
# in getcwd.rst
.. py:module:: os
.. py:function:: getcwd()
```
```
# in system.rst
# use `:noindex:` not to create a cross-reference target to avoid conflicts
.. py:module:: os
   :noindex:

.. py:function:: system()
```

Unfortunately, it is strongly coupled with cross-reference system. So this is very difficult problem.
Ideally there would be `:noxref:` for this and `:noindex:` for the index, but I realise that would break backward compatibility :disappointed: 

Perhaps, add new flags `:noxref:` and `:skipindex:` wherever `:noindex:` is allowed. Ignore these flags unless a specific setting is enabled in the environment via `conf.py`, say `enable_noxref`. It defaults to disabled, so current behaviour is maintained exactly. If it _is_ enabled, then:
* If an ambiguity arises during cross-referencing, user is warned to use `:noxref:` for the entry which will not be cross-referenced. Since an entry so marked isn't to be cross-referenced, it won't show up in the index and won't be cross-referencable/permalinkable.
* If a node is marked with `:skipindex:`, no entry for it will be added in the index, but it will still be able to be cross-referenced/permalinked, as long as it is not marked `:noxref:`.

What do you think?
@vsajip Have you found a workaround in the meantime?
> Have you found a workaround in the meantime?

No, unfortunately not. I think what I suggested is the appropriate fix, but waiting for feedback on this from the maintainers.
I believe some of the problem may be related to documentation, for what ``noindex`` actually means.
One way to view it is that we have 3 things in play:
1. Recording a declaration in the internal index in a domain (and show a perma-link).
2. Cross-referencing declarations (requires (1) to have happened).
3. Showing links to declarations in a generated index  (requires (1) to have happened).

For the domains declarations that support ``noindex`` I believe in all cases it suppresses (1), making suppression of  (2) and (3) incidental. From this (somewhat technical) point of view, the name makes sense, and basically makes a declaration not exist (except for a visual side-effect). Though, in hindsight the name ``noindex`` is probably too ambiguous.
We should improve the documentation to make this clear (after checking that this is how all domains handle it (and maybe implement it in the directives that don't support it yet)).

At this point I can not imagine a use case where suppression of (2) but not (1) makes sense.

Do I understand it correctly that you would like to suppress (3) but keep (1) and (2)?
That is not unreasonable, and we should then come up with a good name for such an option.

(We could also invent a new name for what ``noindex`` does and reuse the name, but this is a really heavy breaking change)
> Do I understand it correctly that you would like to suppress (3) but keep (1) and (2)

Well, the ability to include/exclude index items is orthogonal to cross-referencing within the documentation. As you've identified, (1) needs to happen always, so that (2) and (3) are not "incidentally" made impossible. (2) is the most useful IMO (follow an intra-document link for more information about something) and (3) is useful but not as much (mainly used when you know the name of what you're looking for). One might want to suppress (3) because it makes the index too voluminous or confusing to include _everything_ that's indexable, for example. The documenter can control (2) by choosing to use a `:ref:` tag or not, as they see fit, but currently can't exercise fine control over (3).
new to sphinx and all that, so I can't comment on all these cases. I came across this issue because in our documentation, we have automodules in our RST docs and at the same time have a autodoc generated files that are accessible through the search bar. One of the two needs the :noindex: as told by sphinx error message, but this also removes/prevents anchor links. 
Right, (2) and (3) are of course orthogonal. There are definitely use-cases for suppressing all (e.g., writing example declarations), but I guess not necessarily used that often.
What I meant by (2) is a bit different: the user can always simply not use one of the xref roles, as you suggest, but by (2) I meant the ability for an xref to resolve to a given declaration, but still that declaration in the index. I believe this is what @tk0miya meant by the comment that ``:noindex`` is strongly coupled with cross-referencing.

Anyway, I guess we are back to looking for a name for the option the suppressed (3) but not (1)?
> new to sphinx and all that, so I can't comment on all these cases. I came across this issue because in our documentation, we have automodules in our RST docs and at the same time have a autodoc generated files that are accessible through the search bar. One of the two needs the :noindex: as told by sphinx error message, but this also removes/prevents anchor links.

I'm not too familiar with autodoc but it doesn't sound like ``:noindex:`` is the right solution. Rather, it sounds like you are effectively documenting things twice?
> I believe this is what @tk0miya meant by the comment that :noindex is strongly coupled with cross-referencing.

I understood it to mean that in the current code base, you can't separate out (2) and (3) - the only thing you have to prevent something appearing in (3) is `:noindex:`, which disables (1) and hence (3), but also (2).
Thank you for your explanation. Yes, both (2) and (3) depend on (1)'s database (the internal index). And the `:noindex:` option disables (1).

But I understand the idea to disable only (3). So +0 if there is good naming for the option. But we need to keep the name and its behavior of `:noindex:` to keep compatibility.

Note: I still don't understand disabling (2) is really needed. So I don't think to add an option to do that at present.
I agree that there is no strong need to disable (2), except to flag a particular target in the case of ambiguities - which should be a rare case. What about the naming I suggested in [the above comment](https://github.com/sphinx-doc/sphinx/issues/7052#issuecomment-578422370), specifically `:skipindex:`?
I don't find ``skipindex`` sufficiently different from ``noindex``. How about ``hideindex``, ``hideindexentry``, or ``noindexentry``? Hiding something is different from not having it, and skipping the addition of an index entry is literally what we are talking about implementing.  I prefer ``noindexentry`` at the moment.
I think we should use a different word for the new option. We already use the "index" at `:noindex:` option. I thought `:skipindex:` and `:hideindex:` are using the same wording. I guess users suppose them to control the same thing that `:noindex:` controls. But they are different behavior. So I feel "indexentry" is better. +1 for `:noindexentry:`.

Note: Ideally, it would be best if we can rename `:noindex:` to new name. But the option has been used for a long time. So we can't do that. So we should choose better name without using "index" keyword.
I'm fine with `:noindexentry:`, too. We can't completely avoid the word `index`, since we're talking about excluding an entry from the index.
> I thought `:skipindex:` and `:hideindex:` are using the same wording. I guess users suppose them to control the same thing that `:noindex:` controls.

I agree with @tk0miya.

+1 for `:noindexentry:`.

> The reason for the as aliases here is to be explicit that these imports are for the purpose of re-export (without having to resort to defining __all__, which is error-prone).

I think ``__all__``is the way to be explicit about the API of a module.That way you have the API documented in one place at the top of the module without having to check what exactly is imported with  ``import x as x``.  I never heard about  ``import x as x`` and never did the implementer of the check, but I saw the mypy documentation you linked, let's see how widely used this is.
I don't think there is a way for pylint to detect if the reexport is intended or not. Maybe we could ignore `__init__.py` files 🤔 However, that might be unexpected to the general user.

Probably the easiest solution in your case would be to add a module level `pylint: disable=useless-import-alias` (before any imports).
Yeah, other linters like mypy specifically support `as` rather than just `__all__` for this, since so many people have been burned by using `__all__`.


`__all__` requires maintaining exports as a list of strings, which are all-too-easy to typo (and often tools and IDEs can’t detect when this happens), and also separately (and often far away) from where they’re imported / defined, which is also fragile and error-prone.
>  tools and IDEs can’t detect when this happens

Yeah I remember when I used liclipse (eclipse + pydev) this was a pain. This is an issue with the IDE though, Pycharm Community Edition handle this correctly.
Sure, some IDEs can help with typos in `__all__`, but that's only one part of the problem with `__all__`. More problematic is that it forces you to maintain exports separately from where they're imported / defined, which makes it too easy for `__all__` to drift out of sync as changes are made to the intended exports.
As @cdce8p said, the solution is to disable. I think this is going to stay that way because I don't see how pylint can guess the intent of the implementer. We could make this check optional but I think if you're making library API using this  you're more able to disable the check than a beginner making a genuine mistake is to activate it. We're going to document this in the ``useless-import-alias`` documentation.
Ok, thanks for that. As usage of mypy and mypy-style explicit re-imports continues to grow, it would be interesting to know how many pylint users end up having to disable `useless-import-alias`, and whether that amount ever crosses some threshold for being better as an opt-in rather than an opt-out. Not sure how much usage data you collect though for such decisions (e.g. by looking at usage from open source codebases).
> crosses some threshold for being better as an opt-in rather than an opt-out

An alternative solution would be to not raise this message in ``__init__.py``.

>  Not sure how much usage data you collect though for such decisions (e.g. by looking at usage from open source codebases).

To be frank, it's mostly opened issues and the thumbs-up / comments those issues gather. I'm not looking specifically at open sources projects for each messages it's really time consuming. A well researched comments on this issue with stats and sources, a proposition that is easily implementable with a better result than what we have currently, or this issue gathering 50+ thumbs up and a lot of attention would definitely make us reconsider.
Got it, good to know.
Just noticed https://github.com/microsoft/pyright/releases/tag/1.1.278

> Changed the `reportUnusedImport` check to not report an error for "from y import x as x" since x is considered to be re-exported in this case. Previously, this case was exempted only for type stubs.

One more tool (pyright) flipping in this direction, fwiw.
We'll need an option to exclude ``__init__`` for the check if this become widespread. Reopening in order to not duplicate info.
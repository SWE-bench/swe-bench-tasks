Boy, I could really use this right away.  If it were up to me:

* `napoleon_custom_sections` would be called `napoleon_custom_aliases`, and only accept a list of `(new alias, existing section)` tuples.
* A hypothetical new `napoleon_custom_sections` would only accept a list of `(new section, existing section)` or `(new section, callback function)` tuples, and the output would always use `new section` as the title, in either case.

That would be a backwards-incompatible change, but you could argue that the current behavior isn’t actually documented in the Sphinx docs, and thus is fair game.

Cheers,
Tim
I also don't know napoleon module has such option. It was added at #4387. It has not been documented, but it was introduced in CHANGES. So I consider it's a secret feature. So -1 for incompatible change.

But I'm interested in the enhancement itself. Could you submit a PR please? I'll take a look.

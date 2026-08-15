FWIW, "Link to this heading" would be a better name IMO -- even though it's a more "drastic" rephrasing. :)

+1; Reasonable. Could you make a PR, please? Then I'll merge this into the master branch.

Note: To keep the message translated, it would be better to change it in the major release.
> FWIW, "Link to this heading" would be a better name IMO

I agree.

"permalink" has a quite specific meaning which I think cannot be guaranteed by Sphinx. In fact, in many cases (probably the majority of sites out there), the generated link will contain something like `latest`, which is definitely *not* a permalink!
> +1; Reasonable. Could you make a PR, please? Then I'll merge this into the master branch.

Happy to! Is there any specific thing that I'd need to do other than modifying the two spots in the codebase that use this string (via `_("Permalink to this headline")`)? Specifically, do the translation files need updating? If so, how should I do that?
It's okay to change the strings only. All translations are managed at transifex.com. And strings on our codebase will be synchronized to transifex.com automatically by weekly batch (see https://github.com/sphinx-doc/sphinx/actions/workflows/transifex.yml)
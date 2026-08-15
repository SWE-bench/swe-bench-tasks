This affected me too on other project and what I find it quite problematic for two reasons:
* it seems that this feature does not work on macos, I get this warning only on linux --- weird
* i do not see any option to silence it and because I use strict mode, it broke the CI
* people may want to avoid using sphinx specific constructs in order to keep the file editable and rendable by more tools

The only workaround that I see now is to pin-down sphinx to `<4.4.0`.
I agree it's needed to control the check feature (#10113 is a related story). I'm not sure it's really needed to control the check by file or individual URL. So I'd like to add an option to enable/disable the checks for the whole of the project.
> I'm not sure it's really needed to control the check by file or individual URL.

I for one like this feature for all my sphinx only files, but then there's an index file used by pypi.org where a file-level exclude list would be helpful. The individual URL disable would be there to bypass bugs of detection without needing to turn off the feature entirely.
>it seems that this feature does not work on macos, I get this warning only on linux --- weird

IMO, this feature is not related to the OS. So I'm not sure why it does not work on macOS. How about call `make clean` before building?

>people may want to avoid using sphinx specific constructs in order to keep the file editable and rendable by more tools

Understandable. The PyPI's case is one of them.

>The individual URL disable would be there to bypass bugs of detection without needing to turn off the feature entirely.

Please let me know what case do you want to disable the check? I can understand the PyPI's case. But another one is not yet.
> Please let me know what case do you want to disable the check? I can understand the PyPI's case. But another one is not yet.

See my first post here https://github.com/sphinx-doc/sphinx/issues/10112#issue-1105628804 with the github actions link being suggested as a user link.
I'm actually fine with reverting #9800 completely. While issuing the warnings actually makes sense for every hardcoded link that can be replaced with `intersphinx` (as suggested in #9626), it's just not worth it with `extlinks` since it now forces to use the roles even for unrelated URLs. In the example listed by @gaborbernat, it would mean
```py
extlinks = {
    "user": ("https://github.com/%s", "@"),
    "feature": ("https://github.com/%s", "feat"),
}
```
and rewriting the link to ``` :feat:`GitHub Actions <actions>` ```, and it's just too much fuzz for a single link.
Hence why I was proposing that the suggestion should only apply if there's no `/` in the part represented by `%s`. I think that'd fix 99% of the cases here.
I think extlinks can accept shortcuts contains `/`. For example, ```:repo:`sphinx-doc/sphinx` ``` should be allowed. So -1 for the rule.
Be that so, but I don't think your commit solves this issue. Adding a global disable flag is not what this issue is about. I purposefully formulated it to keep the feature but allow disabling it where the check makes invalid suggestions :thinking: 
Indeed. My PR and your trouble are different topics. So the title of the PR is not good.
> I think extlinks can accept shortcuts contains `/`. For example, `` :repo:`sphinx-doc/sphinx` `` should be allowed. So -1 for the rule.

I'd also like to keep the possibility of using `/` in the replacement string.  Example: `` :pull:`1234/files` `` for directly linking to a PR's diff view.  Noticed this while working on https://github.com/syncthing/docs.  Glad to see activity on a quick fix in #10126.
> I'd also like to keep the possibility of using `/` in the replacement string. Example: `` :pull:`1234/files` `` for directly linking to a PR's diff view.

But that's not what I said. I've said for full links where we'd suggest someone use an extlink only make the suggestion if the would-be replacement part `%s` would not contain a `/`. E.g. for `magic.com/a/b` with `extlink= {"m": "magic.com/%s" }` don't suggest because `%s` would be `a/b`, but do warn for `magic.com/c`. If the users already typed out an extlink (the situation you're describing) we'll not warn and we should not impose any restrictions.
Okay sorry I misunderstood. You're only concerned about which cases are considered for the warning, not what actually works in the extlink roles. My bad, sorry for the noise. 
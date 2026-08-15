I have a PR that implements this incoming.
​https://github.com/django/django/pull/14730
OK, I guess we can do something here — it probably is a source of confusion. The same issue was raised in #18021 (but as an invalid bug report, rather than suggesting improving the messaging). Looking at the PR — I'm sceptical about just raising an error — this will likely break code in the wild. Can we investigate adding a system check here instead? There are several similar checks for related fields already: ​https://docs.djangoproject.com/en/3.2/ref/checks/#related-fields
Same issue also came up in #12641
Absolutely. A system check is a much better approach than my initial idea of the error. I have changed the patch to use a system check.
Unchecking patch needs improvement as instructed on the page, (pending reviewer acceptance of course).
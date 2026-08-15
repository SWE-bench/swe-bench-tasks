If one can tell in advance where they are redirected, might as well use the direct link in the docs and skip the redirect.
Perhaps a step forward would be a new setting to treat redirects as errors?
I provided a reason why I want to be able to link to a redirect, unless you think the base URL of sphinx itself should not be linkable?
I misread the issue originally, I was hoping all redirects could be replaced by the final version of the URL, but that’s not true.
In the provided example, sphinx-doc.org could redirect to a different language based on your language preferences. Replacing the link with the final version would force users to visit the English version of the page.

What do you think of a mapping in the config: `{"original_URL": final_url}`, perhaps named `linkcheck_validate_redirects`?
The behavior upon redirect would be:
- original URL present in the mapping, verify the final URL matches the value from `linkcheck_validate_redirects`,
- original URL not present, mark link as broken.
For the sphinx-doc.org case I would not expect to specify the exact final URL because I don't care where it redirects to when I link to `/`. (It may decide that CI in another country should get a different language by default.)

If `final_url` could be `None` to allow any final URL, that would appear to work but I'd really want it to redirect within the same domain. If https://www.sphinx-doc.org/ redirects to https://this-domain-is-for-sale.example.com/sphinx-doc.org then the link is broken.

So `final_url` could be `None`, a string or a regex.

```
{"https://www.sphinx-doc.org/": None}
```

```
{"https://www.sphinx-doc.org/": "https://www\.sphinx-doc\.org/en/master/"}
```

```
import re
{"https://www.sphinx-doc.org/": re.compile(r"^https://www\.sphinx-doc\.org/.*$")}
```

Of course, when you start allowing regex in the `final_url`you might want to allow regex in the `original_url` and group references:

```
import re
{re.compile("^https://sphinx-doc.org/(.*)$"): re.compile(r"^https://(www\.)?sphinx-doc\.org/\1$")}
```

There may be multiple conflicting mappings, if any one of them matches then the link is ok.
This is something I have just come across myself, and such a setting would be helpful to ignore the fact that a redirect happened - in other words, set the state as "working" instead of "redirected" as long as the target page is available.

Another example of a case where this would be helpful is wanting to ignore redirects in the case of documentation versions, e.g. `.../en/stable/` → `.../en/3.2/`. In this case it is preferable to always link to the latest/stable version via a URL rewrite.

I could see a configuration along the following lines (very much what @nomis has specified above):

```python
# Check that the link is "working" but don't flag as "redirected" unless the target doesn't match.
linkcheck_redirects_ignore = {
    r'^https://([^/?#]+)/$': r'^https://\1/(?:home|index)\.html?$',
    r'^https://(nodejs\.org)/$', r'^https://\1/[-a-z]+/$',
    r'^https://(pip\.pypa\.io)/$', r'^https://\1/[-a-z]+/stable/$',
    r'^https://(www\.sphinx-doc\.org)/$', r'^https://\1/[-a-z]+/master/$',
    r'^https://(pytest\.org)/$', r'^https://docs\.\1/[-a-z]+/\d+\.\d+\.x/$',
    r'^https://github.com/([^/?#]+)/([^/?#])+/blob/(.*)$': r'https://github.com/\1/\2/tree/\3$',
    r'^https://([^/?#\.]+)\.readthedocs\.io/$': r'^https://\1\.readthedocs\.io/[-a-z]+/(?:master|latest|stable)/$',
    r'^https://dev\.mysql\.com/doc/refman/': r'^https://dev\.mysql\.com/doc/refman/\d+\.\d+/',
    r'^https://docs\.djangoproject\.com/': r'^https://docs\.djangoproject\.com/[-a-z]+/\d+\.\d+/',
    r'^https://docs\.djangoproject\.com/([-a-z]+)/stable/': r'^https://docs\.djangoproject\.com/\1/\d+\.\d+/',
}
```
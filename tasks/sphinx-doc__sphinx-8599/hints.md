Thank you for proposal. I agree with your idea. But it would better to customize it via CSS to me. How about wrapping these labels with `<span>`? Adding a custom node will cause incompatibility to writers. Please take a look errors in Travis CI.
I agree that adding a custom node might be to invasive, but I don't know how else it would be possible to influence the generated HTML.

Tests seem to pass now, but I don't know whether `getattr` is the correct approach for that.
Hmm, the unused import that https://travis-ci.org/sphinx-doc/sphinx/jobs/555878900 complains about, seems to be used in the type annotation comments.
I've updated the pull request and removed the changes to the viewcode link. So there are no longer any custom nodes introduced by the patch. Only the option `html_add_permalinks_html` remains. Is there any chance for this patch to be merged?
Finally, I determined to support custom link text for permalinks. But it is not better to provide two ways to change the link text; `html_add_permalinks` and `html_add_permalinks_html`. Now I'm thinking about a new interface to control link text.

* `html_permalinks = True | False`: Enable or disable permalinks feature.
* `html_permalinks_icon = "¶"`: A text for the label of permalink. HTML tags are allowed.

Note: I think "add" prefix is a bit strange for the configuration name. So the new interface does not use it.

@shimizukawa Please let me know your idea if you have. 
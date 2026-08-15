cc: @pllim
I wouldn't have suspected Sphinx itself. Thanks for investigating!
@larrybradley @pllim @adamtheturtle thanks for reporting this (both here and in #11532).  The [regression](https://github.com/sphinx-doc/sphinx/pull/11432#discussion_r1279598982) was indeed introduced in #11432.

I'm working on fix for this and hope to have that in place relatively soon - a fixup should optimistically be available within the next few days.

Despite the problem, to try to make the most of a learning opportunity: could I ask out of curiosity why you prefer to run linkchecking with anchor checking disabled?
@jayaddison Thanks.  It's been so long that I don't even recall setting `linkcheck_anchors = False`. Perhaps it was because of this statement from the docs:
"Since this requires downloading the whole document, it’s considerably slower when enabled."

I may just switch to `linkcheck_anchors = True`.
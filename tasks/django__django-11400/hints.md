Sample project illustrating the problem. Navigate to /admin/foo/book and observer the order of Author in the list filters.
Screenshot of RelatedOnlyFieldListFilter not ordering items.
OK, yes, seems a reasonable suggestion if you'd like to work on it.
Hello. We've updated our django recently and faced this bug. For me it seems like a quite big regression. As I see in PR, patch was updated and appropriate tests were added too so I suggest to consider including it in 2.2.4 and backporting to (at least) 2.1.
As far as I'm concerned it's not a regression and doesn't qualify for a backport. It's on my list and should be fixed in Django 3.0.
I closed #30703 as a duplicate. It is a regression introduced in #29835.
Alternative ​PR.
I'd argue it is a regression. It worked before and is clearly broken now. Any workarounds for the moment?
Replying to tinodb: I'd argue it is a regression. It worked before and is clearly broken now. Any workarounds for the moment? Yes we marked this as a regression and release blocker (please check my previous comment).
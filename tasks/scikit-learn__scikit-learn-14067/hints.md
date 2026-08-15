Thanks for the report. After a quick check `ARDRegression` uses `pinvh` from scipy. The cutoff factor for small singular values  was recently changed in https://github.com/scipy/scipy/pull/10067 it might be worth setting the previous value in scikit-learn code and see if that allows you to reproduce previous results.
Thanks for the suggestion, I'll see if I can pin that down.
that's not the first time this change is causing issues in our code https://github.com/scikit-learn/scikit-learn/pull/13903
Yep, a quick-and-dirty [patch](https://github.com/timstaley/scikit-learn/commit/742392269794167ba329b889d77947dd391692fc) confirms this is due to the aforementioned pinvh cond changes 
(https://github.com/scipy/scipy/pull/10067)

I'll try and clean that up into something more readable and maintainable, making it clear what's a 'choose_pinvh_cutoff' subroutine and that the current option is to just match default scipy behaviour pre 1.3.0.
That should revert the accuracy regression, while leaving room if anyone wants to have a think about a more rigorous approach to computing a sensible pinvh cutoff value (not something I'm up to speed on personally).
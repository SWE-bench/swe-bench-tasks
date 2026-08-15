Currently the code looks like:
https://github.com/matplotlib/matplotlib/blob/9caa261595267001d75334a00698da500b0e4eef/lib/matplotlib/backends/backend_ps.py#L80-L85
so slightly different sorting. I guess that
`sorted(papersize.items(), key=lambda v: v[1])` will be better as it gives:
```
{'a10': (1.02, 1.46),
 'b10': (1.26, 1.76),
 'a9': (1.46, 2.05),
 'b9': (1.76, 2.51),
 'a8': (2.05, 2.91),
 'b8': (2.51, 3.58),
 'a7': (2.91, 4.13),
 'b7': (3.58, 5.04),
 'a6': (4.13, 5.83),
 'b6': (5.04, 7.16),
 'a5': (5.83, 8.27),
 'b5': (7.16, 10.11),
 'a4': (8.27, 11.69),
 'letter': (8.5, 11),
 'legal': (8.5, 14),
 'b4': (10.11, 14.33),
 'ledger': (11, 17),
 'a3': (11.69, 16.54),
 'b3': (14.33, 20.27),
 'a2': (16.54, 23.39),
 'b2': (20.27, 28.66),
 'a1': (23.39, 33.11),
 'b1': (28.66, 40.55),
 'a0': (33.11, 46.81),
 'b0': (40.55, 57.32)}
```
This issue has been marked "inactive" because it has been 365 days since the last comment. If this issue is still present in recent Matplotlib releases, or the feature request is still wanted, please leave a comment and this label will be removed. If there are no updates in another 30 days, this issue will be automatically closed, but you are free to re-open or create a new issue if needed. We value issue reports, and this procedure is meant to help us resurface and prioritize issues that have not been addressed yet, not make them disappear.  Thanks for your help!
Based on the discussions in #22796 this is very hard to fix in a back compatible way. (But easy to fix as such.)

There were some discussions if we actually require ps, as most people probably use eps anyway. One solution is to introduce a pending deprecation for ps and see the reactions?
My preference would be to completely deprecate and then drop papersize, and make ps output at the size of the figure, like all other backends.  We *could* (if there's really demand for it) additionally support `figsize="a4"` (and similar), auto-translating these to the corresponding inches sizes (this would not be equivalent to papersize, as the axes would default to spanning the entire papersize minus the paddings).
Talked about this on the call, the consensus was to remove the "auto" feature.
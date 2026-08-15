_From Georg Brandl on 2013-03-30 11:44:40+00:00_

Closes #1112: Avoid duplicate download files when referenced from documents in
different ways (absolute/relative).

→ <<cset 181b075251e0f21fa19e4a7be9dd380d392135ae>>

_From Georg Brandl on 2013-03-30 11:44:59+00:00_

Thanks for the report!

_From [Tawez](https://bitbucket.org/Tawez) on 2013-04-02 12:37:00+00:00_

Proposed solution works for downloads,
but doesn't work for images.

I think this would be a better fix:

```
#!python

def relfn2path(self, filename, docname=None):
    # ...
    try:
        return path.normpath(rel_fn), path.normpath(path.join(self.srcdir, rel_fn))
    except UnicodeDecodeError:
        return path.normpath(rel_fn), path.normpath(path.join(self.srcdir, enc_rel_fn))

```

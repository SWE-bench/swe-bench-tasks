Sorry for the inconvenience. Indeed, this must be a bug. I'll take a look this later.
Thank you for fixing it, let me know when a release it done so I can restart my builds
@williamdes  Please follow #7453. I'll work for release maybe tomorrow.
Thank you :rocket: 
From the PR I could see linked, did you add a test case for what I sent ?

```
MySQL
   blablabla

mysql
   blablabla duplicate in lowercase

```
No. The reason of this problem is that sphinx makes the keywords downcase on storing to the internal database. So it's okay only to confirm the stored keyword is not downcased.
Okay, I understand
So is this change on purpose?

I mean, do we have to change the casing of all terms on all our projects testing site with `-W`, or e.g. travis will fail?
No, the change was not intended. And it was fixed at 3.0.1.
For a project of mine, it doesn't look fixed.

See these 2 travis-builds of 2 successive commits, then only difference being the casing of the terms [has been equalized](https://github.com/ankostis/wltp/compare/865cf5dd1eba...f742e9424702).

- [terms with different casing](https://travis-ci.org/github/ankostis/wltp/jobs/676281731): 
- [terms casing all equal](https://travis-ci.org/github/ankostis/wltp/jobs/676292063)

You maych check the pip-list to verify that sphinx-3.0.1 it is, indeed.
I only had to fix references to the glossary but not the glossary itself
https://github.com/phpmyadmin/phpmyadmin/commit/41c1e360d4c162a28e8c6f0949f47aaf467cb2cd
Seems a bit crap to introduce a breaking change on a point release. This breaks resolving terms in a case insensitive fashion.
Okay, I understand what you're saying. It is also not an intended change. Now they become case-sensitive. But they should keep working. I'll work for it soon.
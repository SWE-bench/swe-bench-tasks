If my understanding is correct, the behavior of anchors in GH came from JavaScript works. There is no anchors without "user-content" prefix in the HTML output. So it's difficult to check the anchor.

Do you remember what version have you used before the update? I'd like to try to reproduce why the old version can handle it correctly.
Hi Takeshi,

thank you for your quick response. I will try to answer your question thoroughly but please bear with me that I might not know every detail.

So, as far as I am involved, I know that we are currently upgrading from Sphinx 1 to Sphinx 3. We can see from https://github.com/crate/crate-docs/commit/1650a5092d6cfad1cacdaf0afc16127e1136a2ac, that we probably used Sphinx 1.7.4 beforehand.

However, I am currently not sure if something might have changed on GitHub's reStructuredText rendering. So, taking that moving target into account, maybe Sphinx isn't even responsible at all for seeing our CI croaking on this detail now. The upgrading to Sphinx 3, which revealed this, might just have been a coincidence.

> There is no anchors without "user-content" prefix in the HTML output.

Exactly.

> If my understanding is correct, the behavior of anchors in GH came from JavaScript works.

I already also thought about whether some JavaScript served by GitHub might be involved to make those anchors (here: `#make-changes`) work (again). However, I haven't investigated into this direction yet, so I can't say for sure.

> So it's difficult to check the anchor.

Absolutely. I also believe that there might be nothing we can do about it. Nevertheless, I wanted to share this story as a reference point for others. Maybe it can also serve as an anchor [sic!] to point this out to the GitHub developers, to check if they had some recent changes on their content rendering engine and whether they might be keen on rethinking the respective updates.

With kind regards,
Andreas.

Hi Takeshi,

apparently, anchors with "user-content" prefix are already around for quite some time, as the references at https://github.com/github/markup/issues/425, https://github.com/MicrosoftDocs/azure-devops-docs/issues/6015, https://github.com/go-gitea/gitea/issues/11896 and https://github.com/go-gitea/gitea/issues/12062 are outlining.

There even seem to be recipes like [1,2] and software solutions like [3,4] which show a way how to apply workarounds for that dilemma.

While I still don't know why this hasn't tripped the linkchecker before on our end, as the implementation coming from https://github.com/sphinx-doc/sphinx/commit/e0e9d2a7 seems to be around since Sphinx 1.2 already, I quickly wanted to share those observations and findings with you.

With kind regards,
Andreas.

[1] https://gist.github.com/borekb/f83e48479aceaafa43108e021600f7e3
[2] https://github.com/sergeiudris/lab.gtihub-markdown-big-doc-header-name-uniqueness-dilemma-2020-09-05
[3] https://github.com/samjabrahams/anchorhub
[4] https://github.com/Flet/markdown-it-github-headings

I tried to check the anchors with Sphinx-1.7.4. And it also fails as the newest one does.
```
root@95d7d9cd8d94:/doc# make clean linkcheck
Removing everything under '_build'...
Running Sphinx v1.7.4
making output directory...
loading pickled environment... not yet created
building [mo]: targets for 0 po files that are out of date
building [linkcheck]: targets for 1 source files that are out of date
updating environment: 1 added, 0 changed, 0 removed
reading sources... [100%] index
looking for now-outdated files... none found
pickling environment... done
checking consistency... done
preparing documents... done
writing output... [100%] index
(line    9) broken    https://github.com/crate/crate-docs-theme/blob/master/DEVELOP.rst#make-changes - Anchor 'make-changes' not found
(line    9) ok        https://github.com/crate/crate-docs-theme/blob/master/DEVELOP.rst#user-content-make-changes

build finished with problems.
make: *** [Makefile:20: linkcheck] Error 1
```

I created a sphinx project via sphinx-quickstart command and modified `index.rst` only as following:
```
.. p documentation master file, created by
   sphinx-quickstart on Sat Mar 20 14:18:21 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to p's documentation!
=============================

https://github.com/crate/crate-docs-theme/blob/master/DEVELOP.rst#make-changes
https://github.com/crate/crate-docs-theme/blob/master/DEVELOP.rst#user-content-make-changes
```

I still don't understand why the linkcheck was succeeded before the update...
Hi Takeshi,

thanks for taking the time to look into this. The most probable reason why that didn't croak before is probably that we might have turned warnings into errors by using the `-W` command line option now. Otherwise, I wouldn't be able to explain it either.

So, I believe it is totally fine to close this issue.

However, if you feel we could improve the Sphinx linkchecker on this matter, I will be happy to submit a patch which takes that topic into account by adding the `user-content-` prefix as another candidate to evaluate valid anchors against, if that would be appropriate at all.

Given that users would still like to use the short anchor variant (like `#make-changes`) for writing down the links (as it will work on Browsers), it would be nice to have that kind of convenience that the linkchecker will not croak on this. Maybe we can attach this feature through another [`linkcheck_anchors` configuration setting](https://www.sphinx-doc.org/en/master/usage/configuration.html#confval-linkcheck_anchors) like `linkcheck_anchors_prefixes`?

With kind regards,
Andreas.

I have some contradictory opinions for this:

* Adding a new confval to prefix the anchor is meaningless. AFAIK, this behavior is only needed for GH. No reason to be configurable.
* It's nice to add code to modify the anchors if the baseurl is GH, instead of configuration. It must be worthy.
* But, I hesitate to add code for the specific website to Sphinx.
  * Because it should track the change of the structure of the website (in this case, GH). It will break suddenly if the structure of the website has changed. So it's a bit fragile. It's tough to support.
  * If we give the special treatment for the specific website, it will bring another special treatment for the website. Somebody will say "Why not supporting this site?".
* I understand GH is very commonly used website. So it's very worthy to give special treatment. And it helps many users. In other words, I think not supporting GH is a kind of defect.
  * We already have `sphinx.ext.githubpages`!
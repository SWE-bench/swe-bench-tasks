Getting the same in a Github Action, started happening yesterday, as the build switched to Sphinx 5:

```
sphinx:
     [echo] Running sphinx-build -D release=28-SNAPSHOT -q -W --keep-going -j auto -b html -d "/home/runner/work/geotools/geotools/docs/target/developer/doctrees" . "/home/runner/work/geotools/geotools/docs/target/developer/html"
     [exec] 
     [exec] Exception occurred:
     [exec]   File "/opt/hostedtoolcache/Python/3.10.4/x64/lib/python3.10/site-packages/docutils/nodes.py", line 654, in __getitem__
     [exec]     return self.children[key]
     [exec] IndexError: list index out of range
     [exec] The full traceback has been saved in /tmp/sphinx-err-f7bvx8hf.log, if you want to report the issue to the developers.
     [exec] Please also report this if it was a user error, so that a better error message can be provided next time.
     [exec] A bug report can be filed in the tracker at <https://github.com/sphinx-doc/sphinx/issues>. Thanks!
```
Hi @cyring  / @aaime -- is your project the Linux kernel? I can't really reproduce this on Windows.

Can you try deleting as much of the docs as possible before it stops failing for a minimal reproducer? It's likely we'll do a [`5.0.1` release](https://github.com/sphinx-doc/sphinx/milestone/127) as there are a few other bugs.

A
@AA-Turner in my case it's the [GeoTools documentation](https://github.com/geotools/geotools/tree/main/docs).
Unfortunately, I cannot reproduce it on my local machine, it only happens on the Github actions... I've tried for a while but don't know enough about python and its dependency management (or at least, that's why I think I'm not able to reproduce).

But oh... this is the output during the pip-action bit that sets up Sphinx, maybe you can figure out something from this?

```
/opt/hostedtoolcache/Python/3.10.4/x64/python -m pip install sphinx requests
Collecting sphinx
  Downloading Sphinx-5.0.0-py3-none-any.whl (3.1 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 3.1/3.1 MB 76.5 MB/s eta 0:00:00
Collecting requests
  Downloading requests-2.27.1-py2.py3-none-any.whl (63 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 63.1/63.1 kB 17.5 MB/s eta 0:00:00
Collecting sphinxcontrib-devhelp
  Downloading sphinxcontrib_devhelp-1.0.2-py2.py3-none-any.whl (84 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 84.7/84.7 kB 21.7 MB/s eta 0:00:00
Collecting sphinxcontrib-jsmath
  Downloading sphinxcontrib_jsmath-1.0.1-py2.py3-none-any.whl (5.1 kB)
Collecting docutils<0.19,>=0.[14](https://github.com/geotools/geotools/runs/6651466756?check_suite_focus=true#step:7:15)
  Downloading docutils-0.18.1-py2.py3-none-any.whl (570 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 570.0/570.0 kB 67.7 MB/s eta 0:00:00
Collecting sphinxcontrib-serializinghtml>=1.1.5
  Downloading sphinxcontrib_serializinghtml-1.1.5-py2.py3-none-any.whl (94 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 94.0/94.0 kB 27.4 MB/s eta 0:00:00
Collecting snowballstemmer>=1.1
  Downloading snowballstemmer-2.2.0-py2.py3-none-any.whl (93 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 93.0/93.0 kB 26.7 MB/s eta 0:00:00
Collecting sphinxcontrib-htmlhelp>=2.0.0
  Downloading sphinxcontrib_htmlhelp-2.0.0-py2.py3-none-any.whl (100 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100.5/100.5 kB 30.2 MB/s eta 0:00:00
Collecting packaging
  Downloading packaging-21.3-py3-none-any.whl (40 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 40.8/40.8 kB 12.6 MB/s eta 0:00:00
Collecting imagesize
  Downloading imagesize-1.3.0-py2.py3-none-any.whl (5.2 kB)
Collecting Pygments>=2.0
  Downloading Pygments-2.12.0-py3-none-any.whl (1.1 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 1.1/1.1 MB 80.5 MB/s eta 0:00:00
Collecting babel>=1.3
  Downloading Babel-2.10.1-py3-none-any.whl (9.5 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 9.5/9.5 MB 95.4 MB/s eta 0:00:00
Collecting Jinja2>=2.3
  Downloading Jinja2-3.1.2-py3-none-any.whl (133 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 133.1/133.1 kB 36.5 MB/s eta 0:00:00
Collecting alabaster<0.8,>=0.7
  Downloading alabaster-0.7.12-py2.py3-none-any.whl (14 kB)
Collecting sphinxcontrib-applehelp
  Downloading sphinxcontrib_applehelp-1.0.2-py2.py3-none-any.whl (121 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 121.2/121.2 kB 38.8 MB/s eta 0:00:00
Collecting sphinxcontrib-qthelp
  Downloading sphinxcontrib_qthelp-1.0.3-py2.py3-none-any.whl (90 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 90.6/90.6 kB 21.1 MB/s eta 0:00:00
Collecting idna<4,>=2.5
  Downloading idna-3.3-py3-none-any.whl (61 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 61.2/61.2 kB 18.6 MB/s eta 0:00:00
Collecting certifi>=2017.4.17
  Downloading certifi-2022.5.18.1-py3-none-any.whl ([15](https://github.com/geotools/geotools/runs/6651466756?check_suite_focus=true#step:7:16)5 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 155.2/155.2 kB 39.2 MB/s eta 0:00:00
Collecting urllib3<1.27,>=1.21.1
  Downloading urllib3-1.26.9-py2.py3-none-any.whl (138 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 139.0/139.0 kB 33.4 MB/s eta 0:00:00
Collecting charset-normalizer~=2.0.0
  Downloading charset_normalizer-2.0.12-py3-none-any.whl (39 kB)
Collecting pytz>=2015.7
  Downloading pytz-2022.1-py2.py3-none-any.whl (503 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 503.5/503.5 kB 69.4 MB/s eta 0:00:00
Collecting MarkupSafe>=2.0
  Downloading MarkupSafe-2.1.1-cp310-cp310-manylinux_2_[17](https://github.com/geotools/geotools/runs/6651466756?check_suite_focus=true#step:7:18)_x86_64.manylinux2014_x86_64.whl (25 kB)
Collecting pyparsing!=3.0.5,>=2.0.2
  Downloading pyparsing-3.0.9-py3-none-any.whl (98 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 98.3/98.3 kB 28.0 MB/s eta 0:00:00
Installing collected packages: snowballstemmer, pytz, alabaster, urllib3, sphinxcontrib-serializinghtml, sphinxcontrib-qthelp, sphinxcontrib-jsmath, sphinxcontrib-htmlhelp, sphinxcontrib-devhelp, sphinxcontrib-applehelp, pyparsing, Pygments, MarkupSafe, imagesize, idna, docutils, charset-normalizer, certifi, babel, requests, packaging, Jinja2, sphinx
Successfully installed Jinja2-3.1.2 MarkupSafe-2.1.1 Pygments-2.12.0 alabaster-0.7.12 babel-2.10.1 certifi-2022.5.[18](https://github.com/geotools/geotools/runs/6651466756?check_suite_focus=true#step:7:19).1 charset-normalizer-2.0.12 docutils-0.18.1 idna-3.3 imagesize-1.3.0 packaging-21.3 pyparsing-3.0.9 pytz-[20](https://github.com/geotools/geotools/runs/6651466756?check_suite_focus=true#step:7:21)[22](https://github.com/geotools/geotools/runs/6651466756?check_suite_focus=true#step:7:23).1 requests-2.27.1 snowballstemmer-2.2.0 sphinx-5.0.0 sphinxcontrib-applehelp-1.0.2 sphinxcontrib-devhelp-1.0.2 sphinxcontrib-htmlhelp-2.0.0 sphinxcontrib-jsmath-1.0.1 sphinxcontrib-qthelp-1.0.3 sphinxcontrib-serializinghtml-1.1.5 urllib3-1.[26](https://github.com/geotools/geotools/runs/6651466756?check_suite_focus=true#step:7:27).9
```
> Hi @cyring / @aaime -- is your project the Linux kernel? I can't really reproduce this on Windows.
> 
> Can you try deleting as much of the docs as possible before it stops failing for a minimal reproducer? It's likely we'll do a [`5.0.1` release](https://github.com/sphinx-doc/sphinx/milestone/127) as there are a few other bugs.
> 
> A

Hello,

The purpose is to build the latest mainstream Linux kernel. 
The working operating system is Linux from the Arch Linux distribution which provides some scripts, named ASP, to build and install the next kernel release: a rolling release.
Among those scripts, is run the kernel html doc which is Sphinx based. That part is failing.

Fyi, I have been doing such kernel build once a week for months/years and this is the first time such issue is encountered.
Be also aware, as rolling release, Arch brings the latest stable software packages and thus Sphinx dependencies, like Python.

Hope it helps, feel free to ask other details.
@cyring Sphinx should save a full log on failure, please could you upload it here?

A
I found a minimal reproducer from @aaime's GeoTools documentation (after working out how to read an XML build script!!):

```python
import shutil
from pathlib import Path

from sphinx.cmd.make_mode import run_make_mode


def write(filename, text): Path(filename).write_text(text, encoding="utf-8")

write("conf.py", '''\
''')

write("index.rst", '''\
:kbd:`blah - blah`
''')

shutil.rmtree("_build", ignore_errors=True)
run_make_mode(["html", ".", "_build", "-T", "-W"])
```

run as `reproducer_10495.py`. The `blah - blah` is important -- there must be a hypen and at least one space. @cyring can you check if a similar construct appears in the Linux docs? (`` :kbd:`[a-z0-9 ]*?( \-| \-| \- )[a-z0-9 ]*?` ``)

A
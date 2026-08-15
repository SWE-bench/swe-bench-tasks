In the meantime I'll try to add the mark registration
Nevermind, the markers are added already somewhere else 

https://github.com/scipy/scipy/blob/main/scipy/conftest.py#L13

So then the speculation is wrong and we don't know what might have caused it. 
My guess is that support for the way you register the marker (`addini_value` in `pytest_configure`) regressed. We will check it.
Thank you I am also double checking whether the mark registration is performed properly. 
Hmm, a setup with `addini_value` in a `pytest_configure` in a conftest does work for me, so there's some additional factor here we need to find in order to be able to bisect. Any debugging you can do for this would be great -- I would have tried myself, but last time I tried to clone scipy and run its tests locally, I gave up at some point :) First thing to check is if the `pytest_configure` in the conftest even executes at all - maybe the bug is there.
I feel you 😃 . Thank you regardless, I have managed to circumvent the errors by explicitly adding the markers to the pytest.ini file (https://github.com/scipy/scipy/pull/15783). So apparently some regression happened somewhere but I guess pytest.ini practice is a better way to go anyways
Indeed, our `conftest.py` is not picked up automatically and I'm not sure what the invocation should be to enforce it or if something has changed in the file discovery mechanism
I'm seeing a conftest.py not picked up either, https://github.com/refnx/refnx/pull/621, 

conftest.py (located in the top level directory of the refnx package) defines fixtures I'd like to use. When I run `pytest --fixtures refnx` the fixtures get detected. When I run `pytest refnx`, all my tests get picked up, but the `refnx/conftest.py` file does not. Consequently all the tests that use the fixture defined in conftest.py Error out.

What's weird is that the these Errors don't appear on any of my Linux test matrix, only on all the macOS and one of the Windows matrix.
We also noticed an unexpected change in behavior in our CI with v7.1.0 that looks related to this.

We're calling `pytest --pyargs module_name` where `module_name` is an installed module and at the same time in the current working directory there is a file that contains a pytest config block with a list of markers.

With v7.1.0, it seems like the fixtures in the installed `module_name.tests.conftest` are not loaded when the local settings are present. If we delete the pytest config block from the local file then the fixtures are loaded and the test suite can run without errors (but with warnings about unknown markers).

It doesn't seem to matter whether the config block is in `setup.cfg` or `pyproject.toml`.

I don't have a proper minimal example at this point, but you can replicate this with:

```
pip install -r https://raw.githubusercontent.com/explosion/thinc/v8.0.14/requirements.txt
pip install thinc==8.0.14
pip install pytest==7.1.0
wget https://raw.githubusercontent.com/explosion/thinc/v8.0.14/setup.cfg
pytest --pyargs thinc.tests.test_config::test_config_roundtrip_disk_respects_path_subclasses
```

The error is a missing fixture:

```
  def test_config_roundtrip_disk_respects_path_subclasses(pathy_fixture):
E       fixture 'pathy_fixture' not found
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, cov, doctest_namespace, monkeypatch, no_cover, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.
```

`pathy_fixture` is defined in `thinc.tests.conftest`: https://github.com/explosion/thinc/blob/v8.0.14/thinc/tests/conftest.py

If you downgrade to `pytest==7.0.1` there are no errors, or if you delete `setup.cfg` with v7.1.0 there are potentially marker warnings but no errors.

We've always had a bit of trouble with the options and marker definitions in `conftest.py` when running the test suite from within an installed module vs. a local directory, so it's possible there's another interaction there. The goal is to add a `--slow` option, but we've never gotten it to work 100% as intended for installed modules. We've mainly been using the local ini file to get rid of the marker warnings in the CI.

There didn't seem to be anything specific to OS or python versions in the CI errors we've seen so far.

<details><summary>pip list for reference:</summary>

```
Package             Version
------------------- -------
asttokens           2.0.5  
attrs               21.4.0 
backcall            0.2.0  
bleach              4.1.0  
blis                0.7.6  
catalogue           2.0.6  
click               8.0.4  
coverage            5.5    
cymem               2.0.6  
Cython              0.29.28
decorator           5.1.1  
defusedxml          0.7.1  
entrypoints         0.4    
executing           0.8.3  
flake8              3.5.0  
hypothesis          6.39.3 
importlib-resources 5.4.0  
iniconfig           1.1.1  
ipykernel           5.1.4  
ipython             8.1.1  
ipython-genutils    0.2.0  
jedi                0.18.1 
Jinja2              3.0.3  
jsonschema          4.4.0  
jupyter-client      7.1.2  
jupyter-core        4.9.2  
jupyterlab-pygments 0.1.2  
MarkupSafe          2.1.0  
matplotlib-inline   0.1.3  
mccabe              0.6.1  
mistune             0.8.4  
ml-datasets         0.2.0  
mock                2.0.0  
murmurhash          1.0.6  
mypy                0.910  
mypy-extensions     0.4.3  
nbclient            0.5.13 
nbconvert           6.1.0  
nbformat            5.1.3  
nest-asyncio        1.5.4  
numpy               1.22.3 
packaging           21.3   
pandocfilters       1.5.0  
parso               0.8.3  
pathy               0.6.1  
pbr                 5.8.1  
pexpect             4.8.0  
pickleshare         0.7.5  
pip                 20.0.2 
pkg-resources       0.0.0  
pluggy              1.0.0  
preshed             3.0.6  
prompt-toolkit      3.0.28 
ptyprocess          0.7.0  
pure-eval           0.2.2  
py                  1.11.0 
pycodestyle         2.3.1  
pydantic            1.8.2  
pyflakes            1.6.0  
Pygments            2.11.2 
pyparsing           3.0.7  
pyrsistent          0.18.1 
pytest              7.1.0  
pytest-cov          2.7.1  
python-dateutil     2.8.2  
pyzmq               22.3.0 
setuptools          60.9.3 
six                 1.16.0 
smart-open          5.2.1  
sortedcontainers    2.4.0  
srsly               2.4.2  
stack-data          0.2.0  
testpath            0.6.0  
thinc               8.0.14 
toml                0.10.2 
tomli               2.0.1  
tornado             6.1    
tqdm                4.63.0 
traitlets           5.1.1  
typer               0.4.0  
types-mock          4.0.11 
typing-extensions   4.1.1  
wasabi              0.9.0  
wcwidth             0.2.5  
webencodings        0.5.1  
wheel               0.37.1 
zipp                3.7.0
```

</details>
@adrianeboyd FWIW I can't reproduce this using your reproducer on Linux:

```
$ python3 -m pytest --pyargs thinc.tests.test_config::test_config_roundtrip_disk_respects_path_subclasses      
================================================ test session starts =================================================
platform linux -- Python 3.10.2, pytest-7.1.0, pluggy-1.0.0
rootdir: /home/florian/tmp/9767, configfile: setup.cfg
plugins: hypothesis-6.39.3, cov-2.7.1
collected 1 item                                                                                                     

.venv/lib/python3.10/site-packages/thinc/tests/test_config.py .                                                [100%]

================================================== warnings summary ==================================================
.venv/lib/python3.10/site-packages/thinc/tests/test_config.py::test_config_roundtrip_disk_respects_path_subclasses
.venv/lib/python3.10/site-packages/thinc/tests/test_config.py::test_config_roundtrip_disk_respects_path_subclasses
  /home/florian/tmp/9767/.venv/lib/python3.10/site-packages/smart_open/smart_open_lib.py:181: PendingDeprecationWarning: 'ignore_ext' will be deprecated in a future release
    warnings.warn("'ignore_ext' will be deprecated in a future release", PendingDeprecationWarning)

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================================== 1 passed, 2 warnings in 0.28s ============================================
```
Hmm, I just reproduced it in a new venv in linux with python 3.8.10, but the first try didn't go well because `wget` saved the file as `setup.cfg.1` instead of `setup.cfg` (so admittedly not the most reproducible instructions).

Here are some links to the actual CI failures if that's helpful: https://dev.azure.com/explosion-ai/Public/_build/results?buildId=16516&view=results

python 3.6 passes because it's using v7.0.1.

The less pithy version (closer to what the CI is doing) would be:

```shell
git clone https://github.com/explosion/thinc
cd thinc
git checkout v8.0.14
pip install -U pip setuptools wheel
pip install -U -r requirements.txt
rm -rf thinc
pip install thinc==8.0.14
pip install pytest==7.1.0
pytest --pyargs thinc.tests.test_config::test_config_roundtrip_disk_respects_path_subclasses
```

And then rename `setup.cfg` and run the `pytest` command again.
I was able to reproduce with that, and could bisect it to 0c98f1923101e5905c54ba07650a043fca374f4b:

```
0c98f1923101e5905c54ba07650a043fca374f4b is the first bad commit
commit 0c98f1923101e5905c54ba07650a043fca374f4b
Author: Ran Benita <ran@unusedvar.com>
Date:   Sat Jan 8 22:41:14 2022 +0200

    config: make confcutdir check a bit more clear & correct
    
    I think this named function makes the code a bit easier to understand.
    
    Also change the check to explicitly check for "is a sub-path of" instead
    of the previous check which only worked assuming that path is within
    confcutdir or a direct parent of it.

 src/_pytest/config/__init__.py | 25 ++++++++++++++++++-------
 src/_pytest/main.py            |  3 +--
 2 files changed, 19 insertions(+), 9 deletions(-)
```

which is part of #9493.
Thanks for bisecting @The-Compiler! That commit makes sense.

I'm not immediately sure what the problem is. Since you already have everything set up, would you mind checking if the following change fixes the problem? (I will do it a bit later if not). It basically gets rid of the "Also" part of the commit, reverting to the previous (somewhat strange) check. Change `_is_in_confcutdir` in `src/_pytest/config/__init__.py` to this:

```py
        if self._confcutdir is None:
            return True
        return path not in self._confcutdir.parents
```
Yes, that fixes it. I can dig into it a bit more later today, ran out of time while taking a first look as a meeting begins soon.
Thanks @The-Compiler. I will try to understand what's going on today and prepare a PR.
We (Ansible) are also facing failures due to this. 
Here is some additional debugging:

```python
    def _is_in_confcutdir(self, path: Path) -> bool:
        """Whether a path is within the confcutdir.

        When false, should not load conftest.
        """
        if self._confcutdir is None:
            return True
        oldret = path not in self._confcutdir.parents
        try:
            path.relative_to(self._confcutdir)
        except ValueError as e:
            if oldret:
                print(f"\nOLD True NEW False:\n  {e}\n  {self._confcutdir=}\n  {path=})")
            return False
        if not oldret:
            print(f"\nOLD False NEW True:\n  {self._confcutdir=}\n  {path=}")
        return True
```

resulting output with the reproducer above:

```
─[florian@aragog 1]──[~/tmp/9767-2/thinc]──[22-03-16]──[18:02]──[git/tags/v8.0.14•]────┄
$ ../.venv/bin/python3 -m pytest -s --pyargs thinc.tests.test_config::test_config_roundtrip_disk_respects_path_subclasses
================================================ test session starts =================================================
platform linux -- Python 3.10.2, pytest-7.1.0.dev251+g4eaa6aee7, pluggy-1.0.0
rootdir: /home/florian/tmp/9767-2/thinc, configfile: setup.cfg
plugins: hypothesis-6.39.3, cov-2.7.1
collecting ... 
OLD True NEW False:
  '/home/florian/tmp/9767-2/.venv/lib/python3.10/site-packages/thinc/tests/test_config.py' is not in the subpath of '/home/florian/tmp/9767-2/thinc' OR one path is relative and the other is absolute.
  self._confcutdir=PosixPath('/home/florian/tmp/9767-2/thinc')
  path=PosixPath('/home/florian/tmp/9767-2/.venv/lib/python3.10/site-packages/thinc/tests/test_config.py'))

OLD True NEW False:
  '/home/florian/tmp/9767-2/.venv' is not in the subpath of '/home/florian/tmp/9767-2/thinc' OR one path is relative and the other is absolute.
  self._confcutdir=PosixPath('/home/florian/tmp/9767-2/thinc')
  path=PosixPath('/home/florian/tmp/9767-2/.venv'))

OLD True NEW False:
  '/home/florian/tmp/9767-2/.venv/lib' is not in the subpath of '/home/florian/tmp/9767-2/thinc' OR one path is relative and the other is absolute.
  self._confcutdir=PosixPath('/home/florian/tmp/9767-2/thinc')
  path=PosixPath('/home/florian/tmp/9767-2/.venv/lib'))

OLD True NEW False:
  '/home/florian/tmp/9767-2/.venv/lib/python3.10' is not in the subpath of '/home/florian/tmp/9767-2/thinc' OR one path is relative and the other is absolute.
  self._confcutdir=PosixPath('/home/florian/tmp/9767-2/thinc')
  path=PosixPath('/home/florian/tmp/9767-2/.venv/lib/python3.10'))

OLD True NEW False:
  '/home/florian/tmp/9767-2/.venv/lib/python3.10/site-packages' is not in the subpath of '/home/florian/tmp/9767-2/thinc' OR one path is relative and the other is absolute.
  self._confcutdir=PosixPath('/home/florian/tmp/9767-2/thinc')
  path=PosixPath('/home/florian/tmp/9767-2/.venv/lib/python3.10/site-packages'))

OLD True NEW False:
  '/home/florian/tmp/9767-2/.venv/lib/python3.10/site-packages/thinc' is not in the subpath of '/home/florian/tmp/9767-2/thinc' OR one path is relative and the other is absolute.
  self._confcutdir=PosixPath('/home/florian/tmp/9767-2/thinc')
  path=PosixPath('/home/florian/tmp/9767-2/.venv/lib/python3.10/site-packages/thinc'))

OLD True NEW False:
  '/home/florian/tmp/9767-2/.venv/lib/python3.10/site-packages/thinc/tests' is not in the subpath of '/home/florian/tmp/9767-2/thinc' OR one path is relative and the other is absolute.
  self._confcutdir=PosixPath('/home/florian/tmp/9767-2/thinc')
  path=PosixPath('/home/florian/tmp/9767-2/.venv/lib/python3.10/site-packages/thinc/tests'))
collected 1 item                                                                                                     

. E

======================================================= ERRORS =======================================================
_______________________ ERROR at setup of test_config_roundtrip_disk_respects_path_subclasses ________________________
file /home/florian/tmp/9767-2/.venv/lib/python3.10/site-packages/thinc/tests/test_config.py, line 352
  def test_config_roundtrip_disk_respects_path_subclasses(pathy_fixture):
E       fixture 'pathy_fixture' not found
>       available fixtures: cache, capfd, capfdbinary, caplog, capsys, capsysbinary, cov, doctest_namespace, monkeypatch, no_cover, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

/home/florian/tmp/9767-2/.venv/lib/python3.10/site-packages/thinc/tests/test_config.py:352
============================================== short test summary info ===============================================
ERROR ::test_config_roundtrip_disk_respects_path_subclasses
================================================== 1 error in 0.26s ==================================================
```

Gonna stop here because I'm somewhat tired and getting more confused the longer I look at this issue to be honest...
> I will try to understand what's going on today and prepare a PR.

Maybe the logs I've mentioned [here](https://github.com/ansible-collections/community.vmware/pull/1235#issuecomment-1067653350) together with our tests in [ansible-collections/community.vmware](https://github.com/ansible-collections/community.vmware) might help you.

I don't know if this really helps you, but I thought it would be worth a try.
OK that makes it clear...

The previous `is_in_confcutdir` check was:

```py
path not in self._confcutdir.parents
```

This excludes paths which are *directly* above confcutdir, e.g. if `confcutdir` is `/a/b/c/`, it will exclude `/`, `/a/`, `/a/b/`. But it *doesn't* exclude `/x/`, `/a/b/x` etc.

The new `is_in_confcutdir` check is:

```py
try:
    path.relative_to(self._confcutdir)
except ValueError:
    return False
return True
```

which rejects everything not under `confcutdir`, e.g. `/x` etc. are rejected.

The documentation of `--confcutdir` says `only load conftest.py's relative to specified dir.` which makes the new behavior sound correct. However, the name "cut" itself as well as c000955dde3ecc12291c8890ba29887d7b6ef1f2 make it sound like the previous behavior was actually the intended one.

The pytest thinc invocation runs the tests out-of-tree - not running against the tests in the source code, but using `--pyargs` which picks the tests from the venv/site-packages. This is not under the confcutdir, so the new behavior now ignores the conftests there. This is definitely a bug.

However the old behavior is pretty weird as well - e.g. consider a setup like this:

```
/home/ran/src/thinc/pytest.ini
/home/ran/python/venvs/venv/lib/python3.10/site-packages/thinc/
```

And we're running `/home/ran/python/venvs/venv/bin/python -m pytest --pyargs thinc.tests`. Then pytest will pick up conftests in each of

```
/home/ran/python/venvs/venv/lib/python3.10/site-packages/
/home/ran/python/venvs/venv/lib/python3.10/
/home/ran/python/venvs/venv/lib/
/home/ran/python/venvs/venv/
/home/ran/python/venvs/
/home/ran/python/
```

which is definitely not expected.

In any case, for now I'll revert to the previous behavior (hopefully I can create a test to ensure it doesn't regress), but will open a follow up issue about the above.
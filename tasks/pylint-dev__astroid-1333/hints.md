I can't seem to reproduce this in my `virtualenv`. This might be specific to `venv`? Needs some further investigation.
@interifter Which version of `pylint` are you using?
Right, ``pip install pylint astroid==2.9.0``, will keep the local version if you already have one, so I thought it was ``2.12.2`` but that could be false. In fact it probably isn't 2.12.2. For the record, you're not supposed to set the version of ``astroid`` yourself, pylint does, and bad thing will happen if you try to set the version of an incompatible astroid. We might want to update the issue's template to have this information next.
My apologies... I updated the repro steps with a critical missed detail: `pylint src/project`, instead of `pylint src`

But I verified that either with, or without, `venv`, the issue is reproduced.

Also, I never have specified the `astroid` version, before. 

However, this isn't the first time the issue has been observed.
Back in early 2019, a [similar issue](https://stackoverflow.com/questions/48024049/pylint-raises-error-if-directory-doesnt-contain-init-py-file) was observed with either `astroid 2.2.0` or `isort 4.3.5`, which led me to try pinning `astroid==2.9.0`, which worked.
> @interifter Which version of `pylint` are you using?

`2.12.2`

Full env info:

```
Package           Version
----------------- -------
astroid           2.9.2
colorama          0.4.4
isort             5.10.1
lazy-object-proxy 1.7.1
mccabe            0.6.1
pip               20.2.3
platformdirs      2.4.1
pylint            2.12.2
setuptools        49.2.1
toml              0.10.2
typing-extensions 4.0.1
wrapt             1.13.3
```

I confirm the bug and i'm able to reproduce it with `python 3.9.1`. 
```
$> pip freeze
astroid==2.9.2
isort==5.10.1
lazy-object-proxy==1.7.1
mccabe==0.6.1
platformdirs==2.4.1
pylint==2.12.2
toml==0.10.2
typing-extensions==4.0.1
wrapt==1.13.3
```
Bisected and this is the faulty commit:
https://github.com/PyCQA/astroid/commit/2ee20ccdf62450db611acc4a1a7e42f407ce8a14
Fix in #1333, no time to write tests yet so if somebody has any good ideas: please let me know!
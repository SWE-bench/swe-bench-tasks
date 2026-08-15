The relevant code that produces the misleading exception.

https://github.com/astropy/astropy/blob/00ccfe76113dca48d19396986872203dc2e978d7/astropy/timeseries/core.py#L77-L82

It works under the assumption that `time` is the only required column. So when a `TimeSeries` object has additional required columns, the message no longer makes sense.

Proposal: change the message to the form of: 

```
ValueError: TimeSeries object is invalid - required ['time', 'flux'] as the first columns but found ['time']
```
Your proposed message is definitely less confusing. Wanna PR? 😸 
I cannot run tests anymore after updating my local env to Astropy 5. Any idea?

I used [`pytest` variant](https://docs.astropy.org/en/latest/development/testguide.html#pytest) for running tests.

```
> pytest  astropy/timeseries/tests/test_common.py

C:\pkg\_winNonPortables\Anaconda3\envs\astropy5_dev\lib\site-packages\pluggy\_manager.py:91: in register
    raise ValueError(
E   ValueError: Plugin already registered: c:\dev\astropy\astropy\conftest.py=<module 'astropy.conftest' from 'c:\\dev\\astropy\\astropy\\conftest.py'>
E   {'2885294349760': <_pytest.config.PytestPluginManager object at 0x0000029FC8F1DDC0>, 'pytestconfig': <_pytest.config.Config object at 0x0000029FCB43EAC0>, 'mark': <module '_pytest.mark' from 'C:\\pkg\\_winNonPortables\\Anaconda3\\envs\\astropy5_dev\\lib\\site-packages\\_pytest\\mark\\__init__.py'>, 'main': <module '_pytest.main' from 
...
...
...
'C:\\pkg\\_winNonPortables\\Anaconda3\\envs\\astropy5_dev\\lib\\site-packages\\xdist\\plugin.py'>, 'xdist.looponfail': <module 'xdist.looponfail' from 'C:\\pkg\\_winNonPortables\\Anaconda3\\envs\\astropy5_dev\\lib\\site-packages\\xdist\\looponfail.py'>, 'capturemanager': <CaptureManager _method='fd' _global_capturing=<MultiCapture out=<FDCapture 1 oldfd=8 _state='suspended' tmpfile=<_io.TextIOWrapper name='<tempfile._TemporaryFileWrapper object at 0x0000029FCB521F40>' mode='r+' encoding='utf-8'>> err=<FDCapture 2 oldfd=10 _state='suspended' tmpfile=<_io.TextIOWrapper name='<tempfile._TemporaryFileWrapper object at 0x0000029FCCD50820>' mode='r+' encoding='utf-8'>> in_=<FDCapture 0 oldfd=6 _state='started' tmpfile=<_io.TextIOWrapper name='nul' mode='r' encoding='cp1252'>> _state='suspended' _in_suspended=False> _capture_fixture=None>, 'C:\\dev\\astropy\\conftest.py': <module 'conftest' from 'C:\\dev\\astropy\\conftest.py'>, 'c:\\dev\\astropy\\astropy\\conftest.py': <module 'astropy.conftest' from 'c:\\dev\\astropy\\astropy\\conftest.py'>, 'session': <Session astropy exitstatus=<ExitCode.OK: 0> testsfailed=0 testscollected=0>, 'lfplugin': <_pytest.cacheprovider.LFPlugin object at 0x0000029FCD0385B0>, 'nfplugin': <_pytest.cacheprovider.NFPlugin object at 0x0000029FCD038790>, '2885391664992': <pytest_html.plugin.HTMLReport object at 0x0000029FCEBEC760>, 'doctestplus': <pytest_doctestplus.plugin.DoctestPlus object at 0x0000029FCEBECAC0>, 'legacypath-tmpdir': <class '_pytest.legacypath.LegacyTmpdirPlugin'>, 'terminalreporter': <_pytest.terminal.TerminalReporter object at 0x0000029FCEBECE50>, 'logging-plugin': <_pytest.logging.LoggingPlugin object at 0x0000029FCEBECFD0>, 'funcmanage': <_pytest.fixtures.FixtureManager object at 0x0000029FCEBF6B80>}
```

Huh, never seen that one before. Did you try installing dev astropy on a fresh env, @orionlee ?
I use a brand new conda env (upgrading my old python 3.7, astropy 4 based env is not worth trouble).

- I just found [`astropy.test()`](https://docs.astropy.org/en/latest/development/testguide.html#astropy-test) method works for me. So for this small fix it probably suffices.

```python
> astropy.test(test_path="astropy/timeseries/tests/test_common.py")
```

- I read some posts online on  `Plugin already registered` error in other projects, they seem to indicate some symlink issues making pytest reading `contest.py` twice, but I can't seem to find such problems in my environment (my astropy is an editable install, so the path to the source is directly used).


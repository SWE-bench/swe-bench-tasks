
Going foward it's probably better to recommend only the conditional requirement https://github.com/pytest-dev/pytest-runner#conditional-requirement
I agree - that section should at least discuss the downsides of using `pytest-runner`.  

IMO we should present the manual option first, then discuss how this bypasses standard packaging tools, advise against it for libraries, and finally point to `pytest-runner` as a quick way to set this up for applications that can afford the extra dependency and may want to use `setup.py`-based testing.
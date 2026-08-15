I am currently experimenting on a fork with my feature request.

I added two conf vars:
- `coverage_print_missing_c_items`
- `coverage_print_missing_py_items`

They default to `False` and when they are set to `True` in `conf.py` the `coverage` builder prints to console. For the output I took the `linkcheck` builder as example.

So normally this gets printed via `logger.info()`:
![info log](https://user-images.githubusercontent.com/43916661/83350241-1f322780-a33b-11ea-9013-7743d3436fce.PNG)

And when set to `quiet` or `warning is error` this gets printed via `logger.warning()`
![warn log](https://user-images.githubusercontent.com/43916661/83350062-aaaab900-a339-11ea-8c7a-8de9a4e7ab67.PNG)

I will clean up the code and make a draft PR. If the idea gets approved I will add tests etc.

EDIT: New screenshot with lines from `test_ext_coverage::test_build`
EDIT2: Added screenshot for warning logger
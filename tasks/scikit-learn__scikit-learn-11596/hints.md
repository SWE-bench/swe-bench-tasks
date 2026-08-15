I don't see why not!

@lesteve suggested we could add something like `pandas.show_versions()` that would print all the relevant information for debugging. For instance, on my laptop, I get,

<details>

```
>>> pd.show_versions()
INSTALLED VERSIONS
------------------
commit: None
python: 3.6.5.final.0
python-bits: 64
OS: Linux
OS-release: 4.11.6-gentoo
machine: x86_64
processor: Intel(R) Core(TM) i5-6200U CPU @ 2.30GHz
byteorder: little
LC_ALL: None
LANG: en_GB.UTF-8
LOCALE: en_GB.UTF-8

pandas: 0.23.0
pytest: 3.5.1
pip: 10.0.1
setuptools: 39.1.0
Cython: 0.27.3
numpy: 1.14.3
scipy: 1.1.0
pyarrow: None
xarray: None
IPython: 6.4.0
sphinx: None
patsy: None
dateutil: 2.7.3
pytz: 2018.4
blosc: None
bottleneck: None
tables: None
numexpr: None
feather: None
matplotlib: 2.2.2
openpyxl: None
xlrd: None
xlwt: None
xlsxwriter: None
lxml: None
bs4: None
html5lib: None
sqlalchemy: None
pymysql: None
psycopg2: None
jinja2: None
s3fs: None
fastparquet: None
pandas_gbq: None
pandas_datareader: None
```
</details>

we certainly don't care about all the dependencies that pandas might, but I agree that for scikit-learn, having  e.g.
 - BLAS information
 - whether "conda" is in path
 - with https://github.com/scikit-learn/scikit-learn/pull/11166 whether the bundled or unbundled joblib is used
 
would be definitely useful for debuging. It's more practical to have small function for those, than a copy passable snippet (particularly if it becomes more complex).

Tagging this for v0.20 as this would be fairly easy to do, and help with the maintenance after the release..

+10 about `sklearn.show_versions()` I edited the issue title.
I think what we want to do:
* add sklearn.show_versions with similar info as pandas.show_versions and whatever we ask for in the ISSUE_TEMPLATE.md
* modify ISSUE_TEMPLATE.md
* amend the docs, this git grep can be handy:
```
❯ git grep platform.platform
CONTRIBUTING.md:  import platform; print(platform.platform())
ISSUE_TEMPLATE.md:import platform; print(platform.platform())
doc/developers/contributing.rst:     import platform; print(platform.platform())
doc/developers/tips.rst:        import platform; print(platform.platform())
sklearn/feature_extraction/dict_vectorizer.py:            " include the output from platform.platform() in your bug report")
```
This might be of help
```py
from sklearn._build_utils import get_blas_info
```
The problem with doing this is that it won't be runnable before 0.20!​

Hi guys, I'm looking at this right now.

Few questions to help me get this done:

- what are the relevant information from the `get_blas_info` that need to be printed ? 
  unfortunately the compilation information is printed (probably through `cythonize`) but not returned.
- shall I restrict the printed python libraries to the main ones ? 
  I'd suggest `numpy`, `scipy`, `pandas`, `matplotlib`, `Cython`, `pip`, `setuptools`, `pytest`.
- is `sklearn/utils` the right place to put it ?
> The problem with doing this is that it won't be runnable before 0.20!​

Good point we can modify only the rst doc for now and delay the changes in .md until the release.

Not an expert, but I think all the `get_blas_info` is useful. About the dependencies, I am not sure look at what pandas is doing and do something similar (they have things about sys.executable, 32bit vs 64bit, bitness which may be useful). It would be good to keep it as short as possible. For example I am not convinced `pytest` makes sense.

> is sklearn/utils the right place to put it ?

You can probably put the code in `sklearn/utils`. I would be in favour of making it accessible at from the root namespace so that you can do `from sklearn import show_versions`




+1 for adding show_versions.
Maybe optionally include the blas stuff?
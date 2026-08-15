Please provide a minimal reproducer project, and additionally test with 'basic' or 'alabaster' to ensure it is not a bug in the pydata theme.

A
@AA-Turner, sorry the bug report is not more thorough.  I probably won't be able to dig into this any further.  Perhaps some of the PyData theme maintainers could take a look and check if this issue is more appropriate for that project: ping @choldgraf, @12rambau
One more data point: the issue also occurs in the Jax documentation, e.g.

* https://jax.readthedocs.io/en/latest/_autosummary/jax.numpy.cross.html
* https://jax.readthedocs.io/en/latest/_autosummary/jax.random.categorical.html

According to their ['conf.py'](https://github.com/google/jax/blob/8ab50371864cfdf8f6c9f0bda5fba61b6bc278e6/docs/conf.py#L154), the theme used by Jax is `'sphinx_book_theme'`.
Sounds like a pydata theme issue indeed! Please open an issue there so others can discuss

https://github.com/pydata/pydata-sphinx-theme

Also the book theme inherits from the pydata theme so it'd make sense that they have the same issue
I have opened a corresponding issue in the pydata theme repo, so I'll close this issue. We can reopen it if the pydata theme devs figure out that the problem is in Sphinx and not the theme.
Actually I just looked into it a little bit, and I think it might be a bug in autodoc and the pygments styling/structure. Here's the HTML of that section in the pydata theme:

```html
<span class="default_value"><span class="pre">-</span> <span class="pre">inf</span></span>
```

Importantly, note there is _a space between the two span elements_. I think that this is generated HTML by autodoc and not theme-specific after all, right?
@choldgraf do you have the reST source that the snippet was generated from?

A
Well as one example from SciPy:

- The rendered docstring is here: https://scipy.github.io/devdocs/reference/generated/scipy.optimize.direct.html
- The python source is here: https://github.com/scipy/scipy/blob/main/scipy/optimize/_direct_py.py#L41-L282
- The rST source is: https://github.com/scipy/scipy/blob/main/doc/source/reference/optimize.minimize-tnc.rst (this isn't quite for the same function but I think this is the general pattern they're following)
- Here's a big rST index that they use to create links as well: https://raw.githubusercontent.com/scipy/scipy/main/doc/API.rst.txt
Minimal reproducer:

```python
import shutil
from pathlib import Path

from sphinx.cmd.make_mode import run_make_mode

def write(filename, text): Path(filename).write_text(text, encoding="utf-8")

write("conf.py", '''\
import os, sys
sys.path.insert(0, os.path.abspath(".."))
extensions = ["sphinx.ext.autodoc"]
''')

write("extra_white.py", '''\
def func(axis=-1):
    ...
''')

write("index.rst", '''\
.. autofunction:: extra_white.func
''')

shutil.rmtree("_build", ignore_errors=True)
run_make_mode(["html", ".", "_build", "-T", "-W"])
```

The spurious extra whitespace is present as Chris notes as a literal space character between the two span elements.

A
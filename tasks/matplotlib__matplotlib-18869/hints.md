It seems that `__version_info__` is the way to go.

### Prior art
- There's no official specification for version tuples. [PEP 396 - Module Version Numbers](https://www.python.org/dev/peps/pep-0396/) only defines the string `__version__`.

- Many projects don't bother with version tuples.

- When they do, `__version_info__` seems to be a common thing:
  - [Stackoverflow discussion](https://stackoverflow.com/a/466694)
  - [PySide2](https://doc.qt.io/qtforpython-5.12/pysideversion.html#printing-project-and-qt-version) uses it.

- Python itself has the string [sys.version](https://docs.python.org/3/library/sys.html#sys.version) and the (named)tuple [sys.version_info](https://docs.python.org/3/library/sys.html#sys.version_info). In analogy to that `__version_info__` next to `__version__` makes sense for packages.

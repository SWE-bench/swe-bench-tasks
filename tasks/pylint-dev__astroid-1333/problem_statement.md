astroid 2.9.1 breaks pylint with missing __init__.py: F0010: error while code parsing: Unable to load file __init__.py
### Steps to reproduce
> Steps provided are for Windows 11, but initial problem found in Ubuntu 20.04

> Update 2022-01-04: Corrected repro steps and added more environment details

1. Set up simple repo with following structure (all files can be empty):
```
root_dir/
|--src/
|----project/ # Notice the missing __init__.py
|------file.py # It can be empty, but I added `import os` at the top
|----__init__.py
```
2. Open a command prompt
3. `cd root_dir`
4. `python -m venv venv`
5. `venv/Scripts/activate`
6. `pip install pylint astroid==2.9.1` # I also repro'd on the latest, 2.9.2
7. `pylint src/project` # Updated from `pylint src`
8. Observe failure:
```
src\project\__init__.py:1:0: F0010: error while code parsing: Unable to load file src\project\__init__.py:
```

### Current behavior
Fails with `src\project\__init__.py:1:0: F0010: error while code parsing: Unable to load file src\project\__init__.py:`

### Expected behavior
Does not fail with error.
> If you replace step 6 with `pip install pylint astroid==2.9.0`, you get no failure with an empty output - since no files have content

### `python -c "from astroid import __pkginfo__; print(__pkginfo__.version)"` output
2.9.1

`python 3.9.1`
`pylint 2.12.2 `



This issue has been observed with astroid `2.9.1` and `2.9.2`

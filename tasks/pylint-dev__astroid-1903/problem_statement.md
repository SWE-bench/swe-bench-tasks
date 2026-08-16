Unhandled AttributeError during str.format template evaluation
### Steps to reproduce

1. Use `astroid` to parse code that provides arguments to a `str.format` template that attempts to access non-existent attributes

```py
daniel_age = 12
"My name is {0.name}".format(daniel_age)  # int literal has no 'name' attribute
```

### Current behavior

1. unhandled `AttributeError` when it attempts to [evaluate the templated string](https://github.com/PyCQA/astroid/blob/8bdec591f228e7db6a0be66b6ca814227ff50001/astroid/brain/brain_builtin_inference.py#L956)

### Expected behavior

1. could raise an `AstroidTypeError` to indicate that the template formatting is invalid

### `python -c "from astroid import __pkginfo__; print(__pkginfo__.version)"` output

`2.13.0-dev0`

Relates to pycqa/pylint#7939.
Unhandled AttributeError during str.format template evaluation
### Steps to reproduce

1. Use `astroid` to parse code that provides arguments to a `str.format` template that attempts to access non-existent attributes

```py
daniel_age = 12
"My name is {0.name}".format(daniel_age)  # int literal has no 'name' attribute
```

### Current behavior

1. unhandled `AttributeError` when it attempts to [evaluate the templated string](https://github.com/PyCQA/astroid/blob/8bdec591f228e7db6a0be66b6ca814227ff50001/astroid/brain/brain_builtin_inference.py#L956)

### Expected behavior

1. could raise an `AstroidTypeError` to indicate that the template formatting is invalid

### `python -c "from astroid import __pkginfo__; print(__pkginfo__.version)"` output

`2.13.0-dev0`

Relates to pycqa/pylint#7939.

This is a bug of autodoc. The return type field is not generated when the info-field-list uses `returns` field instead of `return` even if `autodoc_typehints_description_target = "documented"`. About this case, napoleon generates a `returns` field internally. It hits the bug.

```
def func1() -> str:
    """Description.

    :return: blah
    """


def func2() -> str:
    """Description.

    :returns: blah
    """
```
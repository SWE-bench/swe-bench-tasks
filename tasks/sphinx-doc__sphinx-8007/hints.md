How did you define the type? If you're using [type aliases](https://mypy.readthedocs.io/en/latest/kinds_of_types.html#type-aliases), it does not define a new type as mypy docs says:

>A type alias does not create a new type. It’s just a shorthand notation for another type – it’s equivalent to the target type except for generic aliases.

I think it is hard to control from Sphinx side.
> How did you define the type? If you're using type aliases 
> <https://mypy.readthedocs.io/en/latest/kinds_of_types.html#type-aliases>, 
> it does not define a new type as mypy docs says:
>
>     A type alias does not create a new type. It’s just a shorthand
>     notation for another type – it’s equivalent to the target type
>     except for generic aliases.
>
> I think it is hard to control from Sphinx side.
>
Thank you for your quick and kind answer. I can see now why Sphinx 
behaves like that.

Although, it is really disappointing. I believe that you agree with me. 
Giving types to parameters serves documenting the code. Type aliases 
make this part of documentation clearer. Until they get automatically 
processed in order for the documentation to look nice...




It would be very nice if realized. Do you have good idea to do that? As my understanding, new static source code analyzer is needed to do that. Please let me know good libraries for that.
Sorry for responding so late. 

I think that the problem comes from relying on the full import mechanism of Python instead of on just its parsing phase. 
There are libraries, such as ast or typed_ast, that build an abstract syntax tree of a script. This tree can further be processed to typeset the script it nicely. Such approach is used, for example, by the 'build' formatter. 
I did an experiment. Its data and results are quoted below. I defined type aliases in two files, a.py and b.py. The a.py script was then subject to parsing by a ast_test.py script. Apparently, the parsing did not unfold the type aliases, they remained just plain identifiers.

What do you think?
Ryszard

##### a.py: #####

from typing import Tuple
from b import T

U = Tuple[int, int]

def f(a: U) -> T:
    """A doc string."""
    return a


##### b.py: #####

from typing import Tuple

T = Tuple[int, int]


##### ast_test.py: #####

from typed_ast import ast3
import astpretty

def main():
    source = open("a.py", "r") 
    tree = ast3.parse(source.read())
    for i in range(len(tree.body)):
        astpretty.pprint(tree.body[i])

if __name__ == "__main__":
    main()


##### Result of 'python3 ast_test.py': #####

ImportFrom(
    lineno=1,
    col_offset=0,
    module='typing',
    names=[alias(name='Tuple', asname=None)],
    level=0,
)
ImportFrom(
    lineno=2,
    col_offset=0,
    module='b',
    names=[alias(name='T', asname=None)],
    level=0,
)
Assign(
    lineno=4,
    col_offset=0,
    targets=[Name(lineno=4, col_offset=0, id='U', ctx=Store())],
    value=Subscript(
        lineno=4,
        col_offset=4,
        value=Name(lineno=4, col_offset=4, id='Tuple', ctx=Load()),
        slice=Index(
            value=Tuple(
                lineno=4,
                col_offset=10,
                elts=[
                    Name(lineno=4, col_offset=10, id='int', ctx=Load()),
                    Name(lineno=4, col_offset=15, id='int', ctx=Load()),
                ],
                ctx=Load(),
            ),
        ),
        ctx=Load(),
    ),
    type_comment=None,
)
FunctionDef(
    lineno=6,
    col_offset=0,
    name='f',
    args=arguments(
        args=[
            arg(
                lineno=6,
                col_offset=6,
                arg='a',
                annotation=Name(lineno=6, col_offset=9, id='U', ctx=Load()),
                type_comment=None,
            ),
        ],
        vararg=None,
        kwonlyargs=[],
        kw_defaults=[],
        kwarg=None,
        defaults=[],
    ),
    body=[
        Expr(
            lineno=7,
            col_offset=4,
            value=Str(lineno=7, col_offset=4, s='A doc string.', kind=''),
        ),
        Return(
            lineno=8,
            col_offset=4,
            value=Name(lineno=8, col_offset=11, id='a', ctx=Load()),
        ),
    ],
    decorator_list=[],
    returns=Name(lineno=6, col_offset=15, id='T', ctx=Load()),
    type_comment=None,
)


This is doable with zero alterations to the Sphinx codebase. All you need is the `annotations` future-import (introduced in [PEP 563](https://www.python.org/dev/peps/pep-0563/) and available in Python >=3.7) and a monkey-patched `typing.get_type_hints`:

```python
import typing
typing.get_type_hints = lambda obj, *unused: obj
```

Sphinx uses `typing.get_type_hints` to [resolve](https://github.com/sphinx-doc/sphinx/blob/7d3ad79392c4fc1ee9ad162b7cc107f391549b58/sphinx/util/inspect.py#L357) string annotations, so the future-import alone is not sufficient. Making this behavior configurable will allow to avoid monkey-patching.
When trying:

```
from __future__ import annotations
import typing
typing.get_type_hints = lambda obj, *unused: obj
```

sphinx_autodocs_typehints fails with 
`AttributeError: '_SpecialForm' object has no attribute 'items'`

That may not be directly related to Sphinx 
Hi, I'm new (to the project and development in general, but I'm a long time Mathematica user) and have been looking into this problem.

The `mathematica.py` file goes thru a table of known functions (of which neither Mathematica `Max` or `Min` functions are in) that are specified with lowercase capitalization, so it might be that doing `mathematica_code(Max(x,2))` is just yielding the unevaluated expression of `mathematica_code`. But there is a problem when I do `mathematica_code(max(x,2))` I get an error occurring in the Relational class in `core/relational.py`

Still checking it out, though.
`max` (lowercase `m`) is the Python builtin which tries to compare the items directly and give a result. Since `x` and `2` cannot be compared, you get an error. `Max` is the SymPy version that can return unevaluated results. 
Bisected to 6ccd2b07ded5074941bb80b5967d60fa1593007a from #21993.

CC @bjodah 
As a work around for now, you can use the `Tuple` object from sympy. Note that it is constructed slightly differently from a python `tuple`, rather than giving a `list`, you give it multiple input arguments (or you can put a `*` in front of your list):
```python
>>> inspect.getsource(lambdify([], Tuple(*[1])))
def _lambdifygenerated():\n    return (1,)\n
>>> inspect.getsource(lambdify([], Tuple(1)))
def _lambdifygenerated():\n    return (1,)\n
```
Of course the problem should also be fixed. `lambdify` is in a bit of an awkward spot, it supports a lot of different input and output formats that make it practically impossible to keep any functionality that is not explicitly tested for whenever you make a change.



> As a work around for now, you can use the `Tuple` object from sympy. Note that it is constructed slightly differently from a python `tuple`, rather than giving a `list`, you give it multiple input arguments (or you can put a `*` in front of your list):

Thank you! This is tested to be working in SymPy 1.6-1.10. Consider this issue addressed for now. 

`lambdify` (or generally, the code generation) is an extremely useful tool. Are you aware of any roadmap or discussions on the refactoring of `lambdify` (or codegen)? I would like to contribute to it. 

I want to put out a 1.10.1 bugfix release. Should this be fixed?
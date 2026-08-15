hmmm...how is that `x` in `exp` not making a request to locals -- or maybe during the parsing at that point the locals was not passed to the parsing subroutine. Not sure.
@smichr any news?
This issue is important for me.

I think there will be a wrong result after this:

https://github.com/sympy/sympy/blob/dc54b1b44f5693772fc4ac698366a424a0845e6e/sympy/parsing/sympy_parser.py#L562

Why if is in `local_dict` this `Symbol` and next token is `(` — this is `Function`? Maybe it should be if this token in `local_dict` is `Function`?

```python
if isinstance(local_dict[name], Function) and nextTokVal == '(':
```

I could fix it myself, but maybe I just don't understand the author's idea. Thanks!

@smichr 
If anyone has the same problem, here is some code that might solve it:
```python
a = parse_expr(
    expr,
    transformations=transformations,
    local_dict=local_dict
)
symbols = a.atoms(Symbol)
for symbol in symbols:
    str_symbol = str(symbol)
    if str_symbol in local_dict:
        a = a.subs(symbol, local_dict[str_symbol])
```
I think this is a legacy issue -- formerly, Symbol would cast to a Function when followed by a left paren. Your proposal looks good.
With your change,
```python
>>> transformations = (standard_transformations +
...                    (implicit_multiplication_application,))
>>> expr2 = 'E**x(1+2*x+(x+1)log(x+1))'
>>> x = var('x', real=True)
>>> p22 = parse_expr(expr2, transformations=transformations, local_dict={'x': x}
)
>>> from sympy.core.symbol import disambiguate as f
>>> f(p22)
((2*x + (x + 1)*log(x + 1) + 1)*exp(x),)  <----- only one symbol, now
```
There is one parsing failure (and there should be) in `test_local_dict_symbol_to_fcn`:
```python
>>> d = {'foo': Symbol('baz')}
>>> parse_expr('foo(x)', transformations=transformations, local_dict=d)
baz*x
>>> parse_expr('foo(x)', local_dict=d)
ValueError: Error from parse_expr with transformed code: "foo (Symbol ('x' ))"

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
...
TypeError: 'Symbol' object is not callable
```
Yes, why should a Symbol be a Function? If it is necessary to parse `foo` as a function, I think you need to specify it in the local_dict: `d = {'foo': Function('baz')}`
I think the I line comment was a rationalization for allowing the legacy behaviour to continue. I think the proper thing to do is raise an error, not to override what the user has declared.
I agree that the transformer shouldn't assume that Symbol()() creates a function since that behavior has been removed, but in general, parse_expr('f(x)') should parse as `Function('f')(Symbol('x'))` if `f` is not already defined. If you want the implicit multiplication to take precedence, you should move that transformer earlier, like `transformations = ((implicit_multiplication_application,) + standard_transformations)`.
Does it make sense for auto_symbol to just skip names entirely if they are already defined in the passed in namespace, or does that break something? 
The error only raises if a name is encountered that is defined as a symbol that is being used as a function, or vice versa:

```python
>>> from sympy import *
>>> from sympy.parsing import *
>>> var('x')
x
>>> from sympy.parsing.sympy_parser import *
>>> transformations = (standard_transformations +(implicit_multiplication_applic
ation,))
>>> parse_expr('f(x)')
f(x)
>>> parse_expr('f(x)',local_dict={'x': Function('y')})
ValueError: Error from parse_expr with transformed code: "Function ('f' )(x )"

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
...
TypeError: Invalid argument: expecting an expression, not UndefinedFunction: y
>>> parse_expr('f(x)',local_dict={'f': Symbol('y')})
ValueError: Error from parse_expr with transformed code: "f (Symbol ('x' ))"

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
...
TypeError: 'Symbol' object is not callable
```
That with the diff
```diff
diff --git a/sympy/parsing/sympy_parser.py b/sympy/parsing/sympy_parser.py
index a74e3a6540..2506663c02 100644
--- a/sympy/parsing/sympy_parser.py
+++ b/sympy/parsing/sympy_parser.py
@@ -13,7 +13,7 @@
 from sympy.core.compatibility import iterable
 from sympy.core.basic import Basic
 from sympy.core import Symbol
-from sympy.core.function import arity
+from sympy.core.function import arity, Function
 from sympy.utilities.misc import filldedent, func_name
 
 
@@ -559,7 +559,7 @@ def auto_symbol(tokens, local_dict, global_dict):
                 result.append((NAME, name))
                 continue
             elif name in local_dict:
-                if isinstance(local_dict[name], Symbol) and nextTokVal == '(':
+                if isinstance(local_dict[name], Function) and nextTokVal == '(':
                     result.extend([(NAME, 'Function'),
                                    (OP, '('),
                                    (NAME, repr(str(local_dict[name]))),
```
Actually this problem is not only for this but also with  _sympify_
Input: `sympify('1 < 2' , evaluate = False)`
Output: `True`
I also tried with _with evaluate(False)_ decorator to prevent this Output but not getting desired result.

Input: `with evalutate(False):`
                 `sympify('1 < 2' , evaluate = False)`
Output: `True`

I want to solve this issue but I am a beginner , If anybody guide me then I am ready to work on this issue.
Thank you!


The `sympify` function calls `parse_expr` if it is given a string so it is `parse_expr` that would need to be fixed.

Right now what is needed is to investigate the code and consider where it can be changed in order to fix this.
parse_expr(evaluate=False) works by handling specific types of nodes when parsing, but it doesn't currently have any support for inequalities. This should be very straightforward to fix. See https://github.com/sympy/sympy/blob/e5643bff2380307190217b8e59142fb3e1b5fd2a/sympy/parsing/sympy_parser.py#L1102
I understand it , Can I fix this issue ?

Correct me if I am wrong anywhere !

`class EvaluateFalseTransformer(ast.NodeTransformer):`
    `operators = {`
        `ast.Add: 'Add',`
        `ast.Mult: 'Mul',`
        `ast.Pow: 'Pow',`
        `ast.Sub: 'Add',`
        `ast.Div: 'Mul',`
        `ast.BitOr: 'Or',`
        `ast.BitAnd: 'And',`
        `ast.BitXor: 'Not',`
        `ast.Equality:'Eq', `
        `ast.Unequality:'Ne',`
        `ast.StrictLessThan:'Lt',`
        `ast.LessThan:'Le',`
        `ast.StrictGreaterThan:'Gt',`
        `ast.GreaterThan:'Ge',`
        
    }
    functions = (
        'Abs', 'im', 're', 'sign', 'arg', 'conjugate',
        'acos', 'acot', 'acsc', 'asec', 'asin', 'atan',
        'acosh', 'acoth', 'acsch', 'asech', 'asinh', 'atanh',
        'cos', 'cot', 'csc', 'sec', 'sin', 'tan',
        'cosh', 'coth', 'csch', 'sech', 'sinh', 'tanh',
        'exp', 'ln', 'log', 'sqrt', 'cbrt',
    )
That looks okay to me.


It shows an Attribute error `AttributeError: module 'ast' has no attribute 'Equality'`
How to fix it ?
I think it's called `ast.Eq`.
How should I fix the error occurring in optional dependencies, Is there any documentation?
> How should I fix the error occurring in optional dependencies, Is there any documentation?

That's a separate problem that is already fixed. When the tests next run that error should be gone.
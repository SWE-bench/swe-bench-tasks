As I dig deeper into this issue, the problem is much larger than `Derivative`. As a matter of facts, all functions should be able to deal with `kind`. At the moment:

```
from sympy import MatrixSymbol
A = MatrixSymbol('A', 2, 2)
sin(A).kind
# UndefinedKind
```
The kind attribute is new and is not fully implemented or used across the codebase.

For `sin` and other functions I don't think that we should allow the ordinary `sin` function to be used for the Matrix sin. There should be a separate `MatrixSin` function for that.

For Derivative the handler for kind just needs to be added.
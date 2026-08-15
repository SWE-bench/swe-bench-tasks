Can I work on this?
Yes, you can.
@Nirvan101 any progress on this?
+1
Since it doesn't subclass from Symbol, it should reapply the logic in the Symbol constructor: https://github.com/sympy/sympy/blob/cd98ba006b5c6d6a6d072eafa28ea6d0ebdaf0e7/sympy/core/symbol.py#L233-L235

Specifically, create a `StdFactKB` from the assumptions that are passed in and set `obj._assumptions` to it. 
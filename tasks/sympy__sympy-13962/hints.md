We could add a flag for it. Also I think the pretty printer should be using the shorter form always. 
Thanks! I created a PR: https://github.com/sympy/sympy/pull/13310
I don't even see a point of adding a flag for it, as one should not provide `abbrev` to a `Quantity` if one does not want it to be used.
OK, there is lots of tests I would need to change, as all of them expect the long output for quantities. Perhaps a switch would be better after all. For those that want the abbreviated display, I am quoting a method suggested by @Upabjojr:
```python
from sympy.printing import StrPrinter
StrPrinter._print_Quantity = lambda self, expr: str(expr.abbrev)
```
I would leave the default printer with the full name. Many abbreviations may be confusing, symbols like `S`, `g`, `m`, `c` may be easily confused with variables (while `meter` and `speed_of_light` are clearly quantities). Maybe we can add a parameter to the printer to specify whether to use `abbrev` or `name`.
Yes, makes sense. So it should be done in `printing.py`? Perhaps it would also be possible to make printing of `2*meter/second` nicer, e.g. `2 m s$^{-1}$`.
There's a way you can pass parameters to the printer. They can be accessed in the printer functions.
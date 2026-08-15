Could you provide the code which generates this?
```
import sympy as sp
w=[sp.Symbol(f'w{i}') for i in range(4)]
ω=[sp.Symbol(f'ω{i}') for i in range(4)]
sp.pprint(w) # -> [w₀, w₁, w₂, w₃]
sp.pprint(ω) # -> [ω0, ω1, ω2, ω3]
```

Not sure what the standard syntax is for defining variables with subscripts, but if you add an underscore between the main part of the variable and the subscript, it should render correctly:

```pycon
>>> ω=[sp.Symbol(f'ω_{i}') for i in range(4)]
>>> sp.pprint(ω)
[ω₀, ω₁, ω₂, ω₃]
```
Ok, thanks.   But I can't see why Greek letters should be treated any differently to Latin.   That's ethnic bias!
This is a bug. They should both work properly. It looks like there is a regular expression in sympy/printing/conventions.py that assumes that the letter parts of symbol names are ASCII letters. It is using `[a-zA-Z]` but it should be using `\w` so that it matches Unicode word characters. 
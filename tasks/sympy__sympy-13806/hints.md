@ungung, thank you for your feedback. We try to keep the github issues in SymPy a bit concrete.
I believe you can get good feedback on our gitter channel, mailing list and stack overflow (where the latter is most suited for questions which may have a general audience).

Am I right to assume that you expect this to give `^\circ`?:
```
>>> from sympy.physics.units import degree
>>> 90*degree
90⋅degree
>>> latex(90*degree)
'90 degree'
```
that would indeed be a nice addition.
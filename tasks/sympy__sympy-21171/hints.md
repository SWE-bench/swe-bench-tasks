Could you provide a fully working example? Copying and pasting your code leaves a number of non-defined variables. Thanks for the report.
@moorepants Sorry for that, I've just updated the code in the original post.
This is the string printed version from `b2..shear_force()`:

```
Out[5]: -F*SingularityFunction(x, L/2, 0) + (F*SingularityFunction(L, 0, -1)*SingularityFunction(L, L/2, 1)/(SingularityFunction(L, 0, -1)*SingularityFunction(L, 0, 1) - SingularityFunction(L, 0, 0)**2) - F*SingularityFunction(L, 0, 0)*SingularityFunction(L, L/2, 0)/(SingularityFunction(L, 0, -1)*SingularityFunction(L, 0, 1) - SingularityFunction(L, 0, 0)**2))*SingularityFunction(x, 0, 0) + (-F*SingularityFunction(L, 0, 0)*SingularityFunction(L, L/2, 1)/(SingularityFunction(L, 0, -1)*SingularityFunction(L, 0, 1) - SingularityFunction(L, 0, 0)**2) + F*SingularityFunction(L, 0, 1)*SingularityFunction(L, L/2, 0)/(SingularityFunction(L, 0, -1)*SingularityFunction(L, 0, 1) - SingularityFunction(L, 0, 0)**2))*SingularityFunction(x, 0, -1)
```
Yes works correctly if you print the string. It throws the error when you display the expression on a jupyter notebook with latex
It errors on this term: `SingularityFunction(L, 0, 0)**2`. For some reasons the latex printer fails on printing a singularity function raised to a power.
In each of these cases, the pprint output is better. I think in general the pretty printer is better tuned than the LaTeX printer, so if they disagree, the pprint output is likely the better one. 

I want to fix this issue. How should I start?

Each of the expressions is a Mul, so look at LatexPrinter._print_Mul and compare it to PrettyPrinter._print_Mul. 

@asmeurer In general what you want is that the output of both should be compared and if the LaTeX printer produces an output different from PrettyPrinter then Pretty Printer's output should be shown in the console. Right ? (A bit confused and posting a comment to clear my doubt)

It shouldn't change the printer type. They should just both produce the same form of the expression. 

@asmeurer Thanks for the clarification. 

Another example:

```
In [7]: var("sigma mu")
Out[7]: (σ, μ)

In [8]: (exp(-(x - mu)**2/sigma**2))
Out[8]:
          2
 -(-μ + x)
 ───────────
       2
      σ
ℯ

In [9]: latex(exp(-(x - mu)**2/sigma**2))
Out[9]: 'e^{- \\frac{1}{\\sigma^{2}} \\left(- \\mu + x\\right)^{2}}'
```

Another one (no parentheses around the piecewise):

```
In [38]: FiniteSet(6**(S(1)/3)*x**(S(1)/3)*Piecewise(((-1)**(S(2)/3), 3*x/4 < 0), (1, True)))
Out[38]:
⎧            ⎛⎧    2/3      3⋅x    ⎞⎫
⎪3 ___ 3 ___ ⎜⎪(-1)     for ─── < 0⎟⎪
⎨╲╱ 6 ⋅╲╱ x ⋅⎜⎨              4     ⎟⎬
⎪            ⎜⎪                    ⎟⎪
⎩            ⎝⎩   1      otherwise ⎠⎭

In [39]: latex(FiniteSet(6**(S(1)/3)*x**(S(1)/3)*Piecewise(((-1)**(S(2)/3), 3*x/4 < 0), (1, True))))
Out[39]: '\\left\\{\\sqrt[3]{6} \\sqrt[3]{x} \\begin{cases} \\left(-1\\right)^{\\frac{2}{3}} & \\text{for}\\: \\frac{3 x}{4} < 0 \\\\1 & \\text{otherwise} \\end{cases}\\right\\}'
```

Some of these were fixed in https://github.com/sympy/sympy/pull/11298

```
In [39]: latex(FiniteSet(6**(S(1)/3)*x**(S(1)/3)*Piecewise(((-1)**(S(2)/3), 3*x/4 < 0), (1, True))))
Out[39]: '\\left\\{\\sqrt[3]{6} \\sqrt[3]{x} \\begin{cases} \\left(-1\\right)^{\\frac{2}{3}} & \\text{for}\\: \\frac{3 x}{4} < 0 \\\\1 & \\text{otherwise} \\end{cases}\\right\\}'
```

This error is caused since there is no closing parentheses included in the printing piecewise functions. Will it be fine to add closing parentheses in Piecewise functions?

The piecewise should print like it does for the Unicode pretty printer. 

I think that these are just different representations of the solution set for the underdetermined system:
```julia
In [25]: x = sympy.symbols('x0:14') 
    ...: print(x) 
    ...: eqs = [x[0]+x[1]-1, x[0]+x[1]+x[2]+x[3]+x[4]+x[5]-2, x[1]+x[6]-1, x[1]+x[4]+x[5]+x[6]+x[7]-1, x[6]+x[8]-1, 
    ...: x[10]+x[5]+x[6]+x[7]+x[8]+x[9]-1, x[11]+x[12]-1, x[11]+x[12]+x[13]-2] 
    ...: s1 = sympy.linsolve(eqs, x)                                                                                                           
(x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13)

In [26]: s2 = sympy.solve(eqs, x) 
    ...:                                                                                                                                       

In [27]: [eq.subs(s2) for eq in eqs]                                                                                                           
Out[27]: [0, 0, 0, 0, 0, 0, 0, 0]

In [28]: [eq.subs(dict(zip(x, list(s1)[0]))) for eq in eqs]                                                                                    
Out[28]: [0, 0, 0, 0, 0, 0, 0, 0]
```
What makes you say that the solution from linsolve is wrong?
Thank you for your answer.
I run the same code but the result is different.
![res](https://user-images.githubusercontent.com/50313027/88110291-e9951680-cbe6-11ea-8711-9b933fc1bf0e.PNG)

You can see that when I use "solve" or "linsolve", the two functions choose the same free variables.
The free variables are "x3, x7, x8, x9, x10, x12".
This is an underdetermined system.
So when you choose the same free variables, you can get only one result.
However, when I use "linsolve", it tells me x5 = -x12 - x3 - x9. (In fact, it is -x10 - x7 - x9).
Note that in the system, x11, x12, x13 have no relation with x0 to x10.
That is why I think it is wrong.
I think the difference is that I tested with master. I can see the same result with sympy 1.6.1:
```julia
In [7]: [eq.subs(dict(zip(x, list(s1)[0]))) for eq in eqs]                                                                                     
Out[7]: [0, x₃ - x₈, 0, x₇ - x₉, -x₁₀ + x₈, -x₁₂ - x₃ + x₇ + x₈, x₁₂ - x₇, x₁₂ - x₇
```
On master I think that linsolve has been changed to use `solve_lin_sys`. Previously I think it used `gauss_jordan_solve` which probably still has the same problem...
Thank you for your answer.
By the way, does "gauss_jordan_solve" use the Gauss Jordan elimination to solve a system of linear equations?
If it is, why the error happens?
I don't know the cause but you can try `gauss_jordan_solve` directly like this:
```julia
In [13]: A, b = linear_eq_to_matrix(eqs, x)                                                                                                    

In [14]: A.gauss_jordan_solve(b)                                                                                                               
Out[14]: 
⎛⎡   1 - τ₂    ⎤      ⎞
⎜⎢             ⎥      ⎟
⎜⎢     τ₂      ⎥      ⎟
⎜⎢             ⎥      ⎟
⎜⎢-τ₀ + τ₁ + 1 ⎥      ⎟
⎜⎢             ⎥      ⎟
⎜⎢     τ₃      ⎥      ⎟
⎜⎢             ⎥      ⎟
⎜⎢   τ₃ + τ₄   ⎥  ⎡τ₀⎤⎟
⎜⎢             ⎥  ⎢  ⎥⎟
⎜⎢-τ₁ - τ₃ - τ₄⎥  ⎢τ₁⎥⎟
⎜⎢             ⎥  ⎢  ⎥⎟
⎜⎢   1 - τ₂    ⎥  ⎢τ₂⎥⎟
⎜⎢             ⎥, ⎢  ⎥⎟
⎜⎢     τ₅      ⎥  ⎢τ₃⎥⎟
⎜⎢             ⎥  ⎢  ⎥⎟
⎜⎢     τ₀      ⎥  ⎢τ₄⎥⎟
⎜⎢             ⎥  ⎢  ⎥⎟
⎜⎢     τ₁      ⎥  ⎣τ₅⎦⎟
⎜⎢             ⎥      ⎟
⎜⎢     τ₂      ⎥      ⎟
⎜⎢             ⎥      ⎟
⎜⎢   1 - τ₅    ⎥      ⎟
⎜⎢             ⎥      ⎟
⎜⎢     τ₄      ⎥      ⎟
⎜⎢             ⎥      ⎟
⎝⎣      1      ⎦      ⎠
```
Checking that leads to
```julia
In [19]: s, p = A.gauss_jordan_solve(b)                                                                                                        

In [20]: [eq.subs(dict(zip(x, s))) for eq in eqs]                                                                                              
Out[20]: [0, -τ₀ + τ₃, 0, -τ₁ + τ₅, τ₀ - τ₂, τ₀ - τ₃ - τ₄ + τ₅, τ₄ - τ₅, τ₄ - τ₅]
```
I think maybe the cause is that the "gauss_jordan_solve" does not do correct Gauss Jordan Elimination.
I try to use MATLAB to do it.
("rref" can get the reduced row echelon form of a matrix by Gauss Jordan Elimination)
The result is correct.
![gauss_jordan](https://user-images.githubusercontent.com/50313027/88115095-5a8cfc00-cbf0-11ea-9ec8-68f5b1f31d33.PNG)

Yes, sympy gives the same for rref:
```julia
In [6]: Matrix.hstack(A, b).rref()                                                                                                             
Out[6]: 
⎛⎡1  0  0  0  0  0  0  0   1   0   0   0  0  0  1⎤                            ⎞
⎜⎢                                               ⎥                            ⎟
⎜⎢0  1  0  0  0  0  0  0   -1  0   0   0  0  0  0⎥                            ⎟
⎜⎢                                               ⎥                            ⎟
⎜⎢0  0  1  1  0  0  0  -1  0   0   0   0  0  0  1⎥                            ⎟
⎜⎢                                               ⎥                            ⎟
⎜⎢0  0  0  0  1  0  0  0   0   -1  -1  0  0  0  0⎥                            ⎟
⎜⎢                                               ⎥, (0, 1, 2, 4, 5, 6, 11, 13)⎟
⎜⎢0  0  0  0  0  1  0  1   0   1   1   0  0  0  0⎥                            ⎟
⎜⎢                                               ⎥                            ⎟
⎜⎢0  0  0  0  0  0  1  0   1   0   0   0  0  0  1⎥                            ⎟
⎜⎢                                               ⎥                            ⎟
⎜⎢0  0  0  0  0  0  0  0   0   0   0   1  1  0  1⎥                            ⎟
⎜⎢                                               ⎥                            ⎟
⎝⎣0  0  0  0  0  0  0  0   0   0   0   0  0  1  1⎦                            ⎠
```
I think the problem is with `gauss_jordan_solve` not `rref`.
Thank you for your answer.
Hope that "sympy" can be better and better.
> ```julia
> In [13]: A, b = linear_eq_to_matrix(eqs, x)                                                                                                    
> 
> In [14]: A.gauss_jordan_solve(b)                                                                                                               
> Out[14]: 
> ⎛⎡   1 - τ₂    ⎤      ⎞
> ⎜⎢             ⎥      ⎟
> ⎜⎢     τ₂      ⎥      ⎟
> ⎜⎢             ⎥      ⎟
> ⎜⎢-τ₀ + τ₁ + 1 ⎥      ⎟
> ⎜⎢             ⎥      ⎟
> ⎜⎢     τ₃      ⎥      ⎟
> ⎜⎢             ⎥      ⎟
> ⎜⎢   τ₃ + τ₄   ⎥  ⎡τ₀⎤⎟
> ⎜⎢             ⎥  ⎢  ⎥⎟
> ⎜⎢-τ₁ - τ₃ - τ₄⎥  ⎢τ₁⎥⎟
> ⎜⎢             ⎥  ⎢  ⎥⎟
> ⎜⎢   1 - τ₂    ⎥  ⎢τ₂⎥⎟
> ⎜⎢             ⎥, ⎢  ⎥⎟
> ⎜⎢     τ₅      ⎥  ⎢τ₃⎥⎟
> ⎜⎢             ⎥  ⎢  ⎥⎟
> ⎜⎢     τ₀      ⎥  ⎢τ₄⎥⎟
> ⎜⎢             ⎥  ⎢  ⎥⎟
> ⎜⎢     τ₁      ⎥  ⎣τ₅⎦⎟
> ⎜⎢             ⎥      ⎟
> ⎜⎢     τ₂      ⎥      ⎟
> ⎜⎢             ⎥      ⎟
> ⎜⎢   1 - τ₅    ⎥      ⎟
> ⎜⎢             ⎥      ⎟
> ⎜⎢     τ₄      ⎥      ⎟
> ⎜⎢             ⎥      ⎟
> ⎝⎣      1      ⎦      ⎠
> ```

Yeah, the free variables are just in the wrong places here. Everything else looks good. I think I got this.
Now it looks like this, which I think is correct:
>```julia
> In [5]: M, B = sympy.linear_eq_to_matrix(eqs, x)
> 
> In [6]: M.gauss_jordan_solve(B)
> Out[6]: 
> ⎛⎡   1 - τ₀    ⎤      ⎞
> ⎜⎢             ⎥      ⎟
> ⎜⎢     τ₀      ⎥      ⎟
> ⎜⎢             ⎥      ⎟
> ⎜⎢-τ₃ + τ₅ + 1 ⎥      ⎟
> ⎜⎢             ⎥      ⎟
> ⎜⎢     τ₃      ⎥      ⎟
> ⎜⎢             ⎥      ⎟
> ⎜⎢   τ₁ + τ₂   ⎥  ⎡τ₀⎤⎟
> ⎜⎢             ⎥  ⎢  ⎥⎟
> ⎜⎢-τ₁ - τ₂ - τ₅⎥  ⎢τ₁⎥⎟
> ⎜⎢             ⎥  ⎢  ⎥⎟
> ⎜⎢   1 - τ₀    ⎥  ⎢τ₂⎥⎟
> ⎜⎢             ⎥, ⎢  ⎥⎟
> ⎜⎢     τ₅      ⎥  ⎢τ₃⎥⎟
> ⎜⎢             ⎥  ⎢  ⎥⎟
> ⎜⎢     τ₀      ⎥  ⎢τ₄⎥⎟
> ⎜⎢             ⎥  ⎢  ⎥⎟
> ⎜⎢     τ₁      ⎥  ⎣τ₅⎦⎟
> ⎜⎢             ⎥      ⎟
> ⎜⎢     τ₂      ⎥      ⎟
> ⎜⎢             ⎥      ⎟
> ⎜⎢   1 - τ₄    ⎥      ⎟
> ⎜⎢             ⎥      ⎟
> ⎜⎢     τ₄      ⎥      ⎟
> ⎜⎢             ⎥      ⎟
> ⎝⎣      1      ⎦      ⎠
>```


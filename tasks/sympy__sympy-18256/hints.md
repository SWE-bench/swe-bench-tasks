I'm having trouble understanding your proposal. Are you proposing to print two completely non-equivalent expressions, `(x**i)**2` and `x**(i**2)`, in an (almost) **indistinguishable** way?

`(x**i)**2 == x**(2*i) != x**(i**2)` 
I'm not sure about this. Seeing both right next to each other, I can see the difference between ![](https://camo.githubusercontent.com/6df60f56328b4dfb10b5355c5fa06fe66392aa2e/68747470733a2f2f6c617465782e636f6465636f67732e636f6d2f6769662e6c617465783f7b785e7b697d7d5e7b327d2c2673706163653b7b785e7b2a7d7d5e7b327d) and ![](https://camo.githubusercontent.com/37fcd12e384e2694f1e838cf42f7edee0bd8ad41/68747470733a2f2f6c617465782e636f6465636f67732e636f6d2f6769662e6c617465783f785e7b695e7b327d7d2c2673706163653b785e7b2a5e7b327d7d), but if I just saw the former by itself I would probably assume it was the latter. It's also general mathematical convention that unparenthesized power towers associate from the right. The nabla-star squared example is a bit unambiguous because nabla star-squared wouldn't make any sense. 

It looks like in the pretty and str printers, both ways parenthesize. The pretty printer can't make symbols smaller, so it often has to use more parentheses than the LaTeX printer. Although IMO the `x**y**z` one probably doesn't need parentheses

```py
>>> pprint((x**y)**z)                                                                                                         
    z
⎛ y⎞ 
⎝x ⎠ 
>>> pprint(x**(y**z))                                                                                                         
 ⎛ z⎞
 ⎝y ⎠
x    
>>> (x**y)**z                                                                                                                 
(x**y)**z
>>> x**y**z                                                                                                                   
x**(y**z)
```
@gschintgen 

`(x**i)**2` is `Pow(Pow(Symbol('x'), i), 2)`. What I am saying about is `Pow(Symbol('x^i'), 2)`.
@asmeurer 

I understand that these two are confusing.  
Still, there are some cases where superscripted symbols without parentheses are preferred.

In the field of engineering, non-dimensionalizing the parameters such as length, time, or temperature is important. Usually, these non-dimensional parameters are denoted as superscripted symbols.  

In this case, parenthesizing all these x^\*, y^\*, z^\*, t^\*, T^\*, (and many more) quickly makes the formula monsterous. This gets even worse when asymptotic expansion is introduced.

Then, how about adding an option to LatexPrinter, which allows the user to toggle this behavior? By default, superscripted symbols will be parenthesized.
> @gschintgen
> 
> `(x**i)**2` is `Pow(Pow(Symbol('x'), i), 2)`. What I am saying about is `Pow(Symbol('x^i'), 2)`.

Thanks for clarifying.
```
In [28]: Pow(Symbol('x^i'), 2)
Out[28]:                                                                                                                 
  2
xⁱ

In [29]: latex(_)
Out[29]: '\\left(x^{i}\\right)^{2}'
```
While `isympy`'s Unicode pretty printer doesn't typeset parentheses (just as you want), the LaTeX printer does. Is that it?

@gschintgen 

That's right. I will add an option to LatexPrinter and see how it does.
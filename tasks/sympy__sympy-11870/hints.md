rewrite can be used:

```
>>> f = S(1) / 2 * (-I*exp(I*k) + I*exp(-I*k))
>>> f.rewrite(sin).simplify()
sin(k)
```

Thank you for that suggestion!

> On Nov 17, 2016, at 01:06, Kalevi Suominen notifications@github.com wrote:
> 
> rewrite can be used:
> 
> > > > f = S(1) / 2 \* (-I_exp(I_k) + I_exp(-I_k))
> > > > f.rewrite(sin).simplify()
> > > > sin(k)
> 
> —
> You are receiving this because you authored the thread.
> Reply to this email directly, view it on GitHub, or mute the thread.

Too bad this doesn't work as expected:

```
ω = sym.symbols('ω', real=True)
k = sym.symbols('k', real=True)
f = 1 / 2 / π * sym.exp(sym.I * ω * k)
F = sym.integrate(f, (ω, -π, π))
F.rewrite(sym.sinc).simplify()
```

It does not produce the desired sinc function in the equation.

It seems that rewrite for sinc has not been implemented.

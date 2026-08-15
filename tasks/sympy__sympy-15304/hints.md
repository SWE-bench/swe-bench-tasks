This is giving the wrong results due to the incorrect logic here https://github.com/sympy/sympy/blob/master/sympy/physics/continuum_mechanics/beam.py#L393. The method we use to handle the end point is only valid for constant and ramp loadings. Here is a test that needs to be added to `test_beam.py`:

```python
def test_parabolic_loads():

    E, I, L = symbols('E, I, L', positive=True, real=True)
    R, M = symbols('R, M', real=True)

    # cantilever beam fixed at x=0 and parabolic distributed loading across
    # length of beam
    beam = Beam(L, E, I)

    beam.bc_deflection.append((0, 0))
    beam.bc_slope.append((0, 0))
    beam.apply_load(R, 0, -1)
    beam.apply_load(M, 0, -2)

    # parabolic load
    beam.apply_load(1, 0, 2)

    beam.solve_for_reaction_loads(R, M)

    assert beam.reaction_loads[R] == -L**3 / 3

    # cantilever beam fixed at x=0 and parabolic distributed loading across
    # first half of beam
    beam = Beam(2 * L, E, I)

    beam.bc_deflection.append((0, 0))
    beam.bc_slope.append((0, 0))
    beam.apply_load(R, 0, -1)
    beam.apply_load(M, 0, -2)

    # parabolic load from x=0 to x=L
    beam.apply_load(1, 0, 2, end=L)

    beam.solve_for_reaction_loads(R, M)

    assert beam.reaction_loads[R] == -L**3 / 3
```
When applying singularity method to an open ended function it's (afaik) impossible to do it in one go, therefore a cut must be made at the end of the load function with a constant that can be evaluated from a second singularity func. starting at the cut, but i believe that implementing this programmatically is tedious.

Nevertheless, a change should be made also in the documentation:
![image](https://user-images.githubusercontent.com/34922526/46165926-341b0580-c292-11e8-8561-e90af6a98ffa.png)

If you cycle through constant, ramp, parabolic, etc that are only applied from 0 to L in at 2L length beam I think the logic follows a pattern like so:

constant load: `v<x-0>^0 - v<x-L>^0`

ramp load: `v<x-0>^1 - vL<x - L>^0 - v<x-L>^1`

parabolic: `v<x-0>^2 - vL^2<x-L>^0 - v theta<x-L>^1 - v<x-L>^2` where theta is the slope of x^2 @ x=L

So, we need to verify the pattern and then write code that can generate this for any order provided.
We could raise an error if `order > 1` and `end is not None` as a quick fix for now. It would just force the user to figure things out manually for order >= 2. But it should be hard to implement the above pattern programmatically.
Little bit of code that is relevant:

```
In [25]: import numpy as np

In [26]: import matplotlib.pyplot as plt

In [27]: x = np.linspace(0, 2 * l)

In [28]: x2 = np.linspace(l, 2 * l)

In [29]: plt.plot(x, x**2)
Out[29]: [<matplotlib.lines.Line2D at 0x7f3fef3979e8>]

In [30]: plt.plot(x2, l**2 * np.ones_like(x2) + 2 * l * (x2- l) + (x2-l)**2)
Out[30]: [<matplotlib.lines.Line2D at 0x7f3fef3b9f98>]

In [31]: plt.show()
```
![figure_1](https://user-images.githubusercontent.com/276007/46167421-98b27200-c24a-11e8-9797-2ac959e12178.png)

We could find a more generalized soulution, if we could find "something" that can represent the function shown by the yellow hatch:
![image](https://user-images.githubusercontent.com/34922526/46167566-6a5a8400-c296-11e8-9f53-99b543d5539c.png)

I just wrote what represents it above: https://github.com/sympy/sympy/issues/15301#issuecomment-425195363
Nice! but I wonder, what is the mathematical solution to this problem!
In the case of a ramp function we use the same consatnt for the function (q) but as the order goes higher the constant changes and i don't know exactly how to calculate it!
I think the mathematical solution is a series that produces the pattern I wrote above.
Maybe taylor Expansion!?
The cubic one fails trying to follow the pattern:

```python
import sympy as sm

x = sm.symbols('x')

v = 2
l = 5

# constant
y = (v * sm.SingularityFunction(x, 0, 0)
     - v * sm.SingularityFunction(x, l, 0))

sm.plot(y, (x, 0, 2 * l))

# linear

y = (v * sm.SingularityFunction(x, 0, 1)
     - v * sm.SingularityFunction(x, l, 1)
     - v * l * sm.SingularityFunction(x, l, 0))

sm.plot(y, (x, 0, 2 * l))

# quadratic

y = (v * sm.SingularityFunction(x, 0, 2)
     - v * sm.SingularityFunction(x, l, 2) -
     - 2 * v * l * sm.SingularityFunction(x, l, 1)
     - v * l**2 * sm.SingularityFunction(x, l, 0))

sm.plot(y, (x, 0, 2 * l))

# cubic

y = (v * sm.SingularityFunction(x, 0, 3)
     - v * sm.SingularityFunction(x, l, 3)
     - 6 * v * l * sm.SingularityFunction(x, l, 2)
     - 3 * v * l**2 * sm.SingularityFunction(x, l, 1)
     - v * l**3 * sm.SingularityFunction(x, l, 0)
     )

sm.plot(y, (x, 0, 2 * l))
```
I think i found a solution!
Its a Taylor series:



```python


#cubic
from mpmath import *

f=v*x**3

fl=f.subs(x,l)
f1=sm.diff(f,x,1).subs(x,l)
f2=sm.diff(f,x,2).subs(x,l)
f3=sm.diff(f,x,3).subs(x,l)

print(f2)
print(sm.diff(f,x,1))
y = (v * sm.SingularityFunction(x, 0, 3)
     -fl*sm.SingularityFunction(x, l, 0)
     -f1*sm.SingularityFunction(x, l, 1)/factorial(1)
     -f2*sm.SingularityFunction(x, l, 2)/factorial(2)
     -f3*sm.SingularityFunction(x, l, 3)/factorial(3)
     )

sm.plot(y, (x, 0, 2 * l))
```

![image](https://user-images.githubusercontent.com/34922526/46177590-b9fb7880-c2b3-11e8-9a71-bf37c5407b1a.png)



Nice, can you try with a quartic?
Failure with x^4 and above!  :/

```python
#power 4
f=v*x**4

f0=f.subs(x,l)
f1=sm.diff(f,x,1).subs(x,l)
f2=sm.diff(f,x,2).subs(x,l)
f4=sm.diff(f,x,3).subs(x,l)
#f5=sm.diff(f,x,4).subs(x,l)
#f6=sm.diff(f,x,5).subs(x,l)
#f7=sm.diff(f,x,6).subs(x,l)
#f8=sm.diff(f,x,7).subs(x,l)


y = (v * sm.SingularityFunction(x, 0, 4)
     -f0*sm.SingularityFunction(x, l, 0)
     -f1*sm.SingularityFunction(x, l, 1)/factorial(1)
     -f2*sm.SingularityFunction(x, l, 2)/factorial(2)
     -f3*sm.SingularityFunction(x, l, 3)/factorial(3)
     -f4*sm.SingularityFunction(x, l, 4)/factorial(4)
     #-f5*sm.SingularityFunction(x, l, 5)/factorial(5)
     #-f6*sm.SingularityFunction(x, l, 6)/factorial(6)
     #-f7*sm.SingularityFunction(x, l, 7)/factorial(7)
     #-f8*sm.SingularityFunction(x, l, 8)/factorial(8)
     )

sm.plot(y, (x, 0, 2 * l))
```
![image](https://user-images.githubusercontent.com/34922526/46178800-938c0c00-c2b8-11e8-8b8f-6c062e2b5124.png)

Quartic seemed to work for me.
This seems to work:

```
f=v*x**4

fl = f.subs(x,l)
f1 = sm.diff(f, x, 1).subs(x, l)
f2 = sm.diff(f, x, 2).subs(x, l)
f3 = sm.diff(f, x, 3).subs(x, l)
f4 = sm.diff(f, x, 4).subs(x, l)

y = (v * sm.SingularityFunction(x, 0, 4)
     - fl*sm.SingularityFunction(x, l,0)
     - f1*sm.SingularityFunction(x, l, 1)/sm.factorial(1)
     - f2*sm.SingularityFunction(x, l, 2)/sm.factorial(2)
     - f3*sm.SingularityFunction(x, l, 3)/sm.factorial(3)
     - f4 * sm.SingularityFunction(x, l, 4)/sm.factorial(4))

sm.plot(y, (x, 0, 2* l))
```
Maybe I have problem in my system;
can you try it with a higher power; 8 for example. 

You have `f4=sm.diff(f,x,3).subs(x,l)` which should have a 4 instead of a 3.
Oh! thats a typo !
It Works!!

```python
f=v*x**8

fl = f.subs(x,l)
f1 = sm.diff(f, x, 1).subs(x, l)
f2 = sm.diff(f, x, 2).subs(x, l)
f3 = sm.diff(f, x, 3).subs(x, l)
f4 = sm.diff(f, x, 4).subs(x, l)
f5 = sm.diff(f, x, 5).subs(x, l)
f6 = sm.diff(f, x, 6).subs(x, l)
f7 = sm.diff(f, x, 7).subs(x, l)
f8 = sm.diff(f, x, 8).subs(x, l)

y = (v * sm.SingularityFunction(x, 0, 8)
     - fl*sm.SingularityFunction(x, l,0)
     - f1*sm.SingularityFunction(x, l, 1)/sm.factorial(1)
     - f2*sm.SingularityFunction(x, l, 2)/sm.factorial(2)
     - f3*sm.SingularityFunction(x, l, 3)/sm.factorial(3)
     - f4 * sm.SingularityFunction(x, l, 4)/sm.factorial(4)
    - f5 * sm.SingularityFunction(x, l, 5)/sm.factorial(5)
     - f6 * sm.SingularityFunction(x, l, 6)/sm.factorial(6)
     - f7 * sm.SingularityFunction(x, l, 7)/sm.factorial(7)
     - f8 * sm.SingularityFunction(x, l, 8)/sm.factorial(8)
    
    )

sm.plot(y, (x, 0, 2* l))
```

![image](https://user-images.githubusercontent.com/34922526/46179217-7e17e180-c2ba-11e8-9905-876a3baf213c.png)

Sweet! Would you like to submit a pull request to add this to the beam module?
I would like to, but I'm not that good with Python.
Would you please do it for us and write the code ?
NP, here is a basic implementation:

```python
def subtract(v, o, l):

    x = sm.symbols('x')

    f = v*x**o

    fl = f.subs(x, l)

    y = (v * sm.SingularityFunction(x, 0, o) -
         fl * sm.SingularityFunction(x, l, 0))

    for i in range(1, o+1):
        y -= sm.diff(f, x, i).subs(x, l)*sm.SingularityFunction(x, l, i)/sm.factorial(i)

    sm.plot(y, (x, 0, 2* l))
```
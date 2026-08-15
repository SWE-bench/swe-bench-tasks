I guess it should be a Boolean in order to do things like x > y => Assume(x - y, Q.positive).

Also, I think just about all Expr methods on a relational should just apply themselves to the lhs and rhs (except 
for inequalities when it would not be correct).  Is there any way to make it do this automatically, for Eq at least?

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c1
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
Issue 2030 has been merged into this issue.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c2
Original author: https://code.google.com/u/101069955704897915480/

I think this is the best place to make this issue.  

In light of issue #5031 and others, I think we need two classes, Eq and Eqn (and ditto for the inequalities).  

One of them would be a Boolean, and would be used for the assumptions.  The other would be a container class for symbolic equalities/inequalities.  The Boolean would auto-reduce to True or False whenever possible.  The other one would never reduce (even if it is something like 1 == 1 or 1 == 2 or Pi > 3).  Arithmetic would work on the symbolic ones ( issue #5031 ).  I'm not sure which one would be called Eq and which Eqn, or what to call the Le, Lt, etc. versions.

I think maybe x > y should return the symbolic version by default, but it would be converted to the boolean version when something like Ask(x >y) or Assume(x > y) was called.  

Ronan, do you agree with this?

Also, postponing the release milestone.

**Summary:** Separate boolean and symbolic relationals  
**Labels:** -Milestone-Release0.7.0 Milestone-Release0.7.1  

Referenced issues: #5031
Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c3
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Blocking:** 5030  

```

Referenced issues: #5030
Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c4
Original author: https://code.google.com/u/asmeurer@gmail.com/

"I'm not sure which one would be called Eq and which Eqn".

IMO, Eq would best fit for a boolean (standing for "equality"), while Eqn would be a symbolic equation, with operations attached to its members.

Also, I think we should have Eq(a, b) always reduced to Eq(a - b, 0), but Eqn(a, b) should be kept as it.

(And docstrings should indicate clearly the differences between both classes, since there is a big risk of confusion anyway...)

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c5
Original author: https://code.google.com/u/117997262464115802198/

The only problem with this is that Eq() is presently used for equations, so it would break compatibility.

What would you suggest naming the inequality functions?

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c6
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
Mmmm... that's not obvious.

First, concerning (symbolic) equations, I successively concidered:

1. Using Ineqn:
---------------
I thought about having an Ineqn(a, b, comp) class. Something like that:
>>> Ineqn(x, 2, '>')
x > 2
>>> Ineqn('x>2')
x > 2
>>> Ineqn('3>2')
3 > 2

(Le, Lt etc. might then be kept as shortcuts for inequations...)

But Ineqn.args should all be of Basic type, so this would require to convert third argument ('>', '<', '>=', '<=' and maybe '!=') to Integers for example, for internal storage. That's feasable but not so elegant.

Nevertheless, I like the name Ineqn, which IMO does not suggest booleans as much as Le or Lt.

2. Keeping Lt, Le...
--------------------
Another option is of course to use Le, Lt... for symbolic inequations, but I don't like it so much, I think it really looks like boolean names.

3. Using GtEqn, LeEqn
---------------------
GtEqn, LeEqn (and so on...) are less ambiguous, but not so short to tape.
>>> GtEqn(x, 2)
x > 2
>>> LeEqn(3, 5)
3 <= 5

For now, I think it's the solution I prefer.




Concerning inequalities:

The real challenge is to find suitable names for symbolic inequations (ie. short and unambiguous ones).

As for (boolean) inequalities,  I think names are not so important, since x < 2 is an easy shortcut.
Also, inequalities (but not inequations) should auto-reduce to True or False in cases like S(3) < S(4) and S(3) > S(4).
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c7
Original author: https://code.google.com/u/117997262464115802198/

```
See comment 3 above.  I think >, <, >=, and <= should default to the symbolic version, but perhaps they could be automatically converted to the boolean version when necessary.  

Thus, we can make it LtEqn, etc. for the equation version (which will have the shortcut of <), and make Lt() be the boolean version.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c8
Original author: https://code.google.com/u/asmeurer@gmail.com/

"I think >, <, >=, and <= should default to the symbolic version, but perhaps they could be automatically converted to the boolean version when necessary."

Well, I don't think they should default to the symbolic version, I think I'd rather expect those to be booleans instead.

Anyway, we have to be sure that things like the following work:
```
if S(2) < S(3):
   print('2 is smaller !')
```
So, if you choose to keep those for the symbolic version, there should indeed be a .__bool__() method attached, to avoid more common misuses (though testing inequalities in such a way might be a bit slow).

If not, it would be *really* confusing.

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c9
Original author: https://code.google.com/u/117997262464115802198/

Of course bool(Le) should work.  That's part of what I meant when I said it should convert to the boolean type automatically.

Consider the main uses of <.  I think that most people will use it in the symbolic sense, like solve(x**2 > x, x).  We can easily convert it to the boolean type if the user says assume(x > 0).  But consider especially that if we follow your suggestion to automatically rewrite a > b as a - b > 0 (for the boolean inequality), then it will not be so easy to convert the boolean inequality to a symbolic inequality, because you will have lost the information about which parts of the expression were on which side of the inequality.

By the way, another thing that bothers me about the inequalities that we might as well fix when we fix this is the way that Ge() is automatically converted to Le().  This leads to things like 0 < x when the user entered x > 0, which looks bad and is confusing.  Of course, internally, they could be store the same (or maybe we could just have properties of all the comparative inequalities like .smaller_part and .large_part (except better names than that), and just use those everywhere.

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c10
Original author: https://code.google.com/u/asmeurer@gmail.com/

> Of course bool(Le) should work.

I have serious doubts about that. bool(x < 3) needs to return either True or False, but neither is really meaningful or obviously correct, and we'll be forced to have bool(x > 3) == bool(Not(x > 3)), which is seriously confusing and dangerous if you try to use a construct like 'if x > 3:'.

Also, I don't really understand what you call "symbolic". Both kinds of objects considered here are symbolic. The boolean inequalities need to be efficient, while the inequations should give complete control to the user and will only be used for presentation. In `solve(x**2 > x, x)`, it's clearly the boolean meaning that is implied: the result should be exactly the same as the one for `solve(x**2 - x > 0, x)` or `solve(x < x**2, x)`.

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c11
Original author: https://code.google.com/u/101272611947379421629/

```
I'd like to do a small 0.7.1 release with IPython 0.11 support, so these will be postponed until 0.7.2.

**Labels:** Milestone-Release0.7.2  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c12
Original author: https://code.google.com/u/asmeurer@gmail.com/

Operators defaulting to bools would make my life substantially easier.

I also think that writing a<3 and expecting a bool is more common than writing a<b as a symbolic inequality. 
```
x = Symbol('x', positive=True)
I'd like x>0 to be True
```
Other issues that affect my code specifically 
Eq(x, x) != True
Ne(x, 0) != True (in the above, x positive example)

The second bit also affects Tom's integration code where any variable might be required to be positive or non-zero.

**Cc:** ness...@googlemail.com  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c13
Original author: https://code.google.com/u/109882876523836932473/

```
**Blocking:** 5719  

```

Referenced issues: #5719
Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c14
Original author: https://code.google.com/u/asmeurer@gmail.com/

> I also think that writing a<3 and expecting a bool is more common than writing a<b as a symbolic inequality. 

Maybe in your use case.  To me, the most common use would be something like solve(x**2 < 1), which should be symbolic.  Also, it's easy to convert a symbolic inequality to a boolean one in the right context, but hard to do the reverse.

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c15
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Blocking:** 5820  

```

Referenced issues: #5820
Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c16
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Blocking:** 5023  

```

Referenced issues: #5023
Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c17
Original author: https://code.google.com/u/101272611947379421629/

```
**Blocking:** 5931  

```

Referenced issues: #5931
Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c18
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
Very optimistically postponing (instead of removing) the milestone...

**Labels:** -Priority-Medium -Milestone-Release0.7.2 Priority-High Milestone-Release0.7.3  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c19
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Blocking:** 6059  

```

Referenced issues: #6059
Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c20
Original author: https://code.google.com/u/asmeurer@gmail.com/

See issue 6059 for some things that need to be fixed in Relationals.  That issue talks mostly about inequalities, but many of them actually apply to all inequalities (e.g., nested Eq() is currently allowed as well).

Referenced issues: #6059
Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c21
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Blocking:** 6078  

```

Referenced issues: #6078
Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c22
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Blocking:** 6116  

```

Referenced issues: #6116
Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c23
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Blocking:** 6204  

```

Referenced issues: #6204
Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c24
Original author: https://code.google.com/u/101272611947379421629/

```
**Status:** Valid  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c25
Original author: https://code.google.com/u/asmeurer@gmail.com/

There was recently a discussion on the maling list about this (actually issue #6204 , but the key here is this issue).  See https://groups.google.com/d/topic/sympy/TTmZMxpeXn4/discussion .

One thing I noted there is that Symbol has exactly the same problem as Relational.  We currently have Symbol as both an Expr and a Boolean.  But clearly we should have both.  We could have intelligent coercion with things like x | y so that it automatically converts a Symbol to a BooleanSymbol, assuming that x and y don't have any assumptions on them that explicitly make them non-boolean.  But whatever we do, the solution for Symbol and the solution for Relational should probably be more or less the same.

Referenced issues: #6204
Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c26
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Blocking:** 5820  

```

Referenced issues: #5820
Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c27
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Blocking:** -sympy:1932 -sympy:1931 -sympy:2620 -sympy:2721 -sympy:1924 -sympy:2832 -sympy:2960 -sympy:2979 -sympy:3017 -sympy:3105 sympy:1932 sympy:1931 sympy:2620 sympy:1924 sympy:2832 sympy:2960 sympy:2979 sympy:3017 sympy:3105 sympy:3105  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c28
Original author: https://code.google.com/u/102137482174297837682/

```
Issue 370 has been merged into this issue.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c29
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
@asmeurer, mind me working on this?
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c30
Original author: https://code.google.com/u/106302547764750990775/

```
Mind? I think it would be great if someone worked on this. 

Take a look at the blocking issues for some inspiration.

**Cc:** -ness...@googlemail.com  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c31
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Labels:** -Milestone-Release0.7.3  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1887#c32
Original author: https://code.google.com/u/asmeurer@gmail.com/

I felt a personal need for an Eqn class so I wrote one to meet my needs, and I've found it very useful. I'm new to sympy and not keen on delving deep into this so maybe I'm missing a better way to do this. I'm afraid I'm not very interested in working this into a pull request, but if somebody else would like to pick it up and add it so Sympy, be my guest.

```
import sympy
from sympy import S
import operator

class Eqn(object):
  """
  This class represents an equation. It is meant for reasoning with equations: adding
  equations, subtracting equations, multiplying them, making substitutions etc.

  >>> from sympy import var
  >>> var('x')
  x
  >>> eq1 = Eqn(2*x, 5)
  >>> eq1 += 4
  >>> eq1.solve()
  {x: 5/2}
  """

  __slots__ = ['sides']

  def __init__(self, *sides):
    self.sides = map(S, sides)

  def map(self, *fs):
    res = self
    for f in fs:
      res = Eqn(*map(f, res.sides))
    return res

  def __iadd__(self, other):
    self.sides = (self+other).sides
    return self

  def __imul__(self, other):
    self.sides = (self*other).sides
    return self

  def __isub__(self, other):
    self.sides = (self-other).sides
    return self

  def __itruediv__(self, other):
    self.sides = operator.truediv(self,other).sides
    return self

  def __rmul__(self, other):
    return self.binary_op(operator.mul, other, self)

  def __radd__(self, other):
    return self.binary_op(operator.add, other, self)

  def __rtruediv__(self, other):
    return self.binary_op(operator.truediv, other, self)

  def __rsub__(self, other):
    return self.binary_op(operator.sub, other, self)

  def __neg__(self):
    return self.map(operator.neg)

  def as_eqs(self):
    return [sympy.Eq(self.sides[i-1], self.sides[i])
            for i in xrange(1, len(self.sides))]

  def solve(self, *args, **kwArgs):
    return sympy.solve(self.as_eqs(), *args, **kwArgs)

  def isolate(self, x):
    solution = sympy.solve(self.as_eqs(), x, dict=True)
    if isinstance(solution,list):
      solution, = solution
    return Eqn(x, solution[x])

  def __str__(self):
    return ' = '.join(map(str,self.sides))

  def foreach(self, *fs):
    for f in fs:
      self.sides = map(f, self.sides)

  def __getitem__(self,idx):
    return self.sides[idx]

  def __setitem__(self,idx,val):
    self.sides[idx] = val

  @classmethod
  def binary_op(cls, op, a, b):
    if isinstance(b, Eqn) and isinstance(a, Eqn):
      return Eqn(*map(op, a.sides, b.sides))
    if isinstance(a, Eqn):
      return Eqn(*[op(x,b) for x in a.sides])
    assert isinstance(b, Eqn)
    return Eqn(*[op(a,y) for y in b.sides])

  def __pow__(self, other):
    return self.binary_op(operator.pow, self, other)

  def __mul__(self, other):
    return self.binary_op(operator.mul, self, other)

  def __truediv__(self, other):
    return self.binary_op(operator.truediv, self, other)

  def __add__(self, other):
    return self.binary_op(operator.add, self, other)

  def __sub__(self, other):
    return self.binary_op(operator.sub, self, other)

  def reverse(self):
    return Eqn(*self.sides[::-1])

  def revert(self):
    self.sides = self.sides[::-1]

  def sides_ratio(self, numerator=1, denominator=0):
    return operator.truediv(self.sides[numerator], self.sides[denominator])

  def sides_diff(self, added=1, subtracted=0):
    return self.sides[added]-self.sides[subtracted]

  def subs(self, other):
    return self.map(lambda s: s.subs(other.sides[0], other.sides[1]))

if __name__=='__main__':
  import doctest
  doctest.testmod()  
```

There is an implementation in the comments here and also in #8023.

I've opened #18053 which makes current `Relational` a proper `Boolean` (not a subclass of `Expr`). What remains is to introduce a new class that implements "symbolic" equations and supports arithmetic operations in the way that users clearly want.
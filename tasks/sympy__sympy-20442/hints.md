Yes, this is a problem. When trying to convert into a unit that is not compatible, it should either do nothing (no conversion), or raise an exception. I personally don't see how the following makes sense:
```
>>> convert_to(meter, second) 
meter

```
I often do calculations with units as a failsafe check. When The operation checks out and delivers reasonable units, I take it as a sign that it went well. When it "silently" converts an expression into non-sensible units, this cannot be used as a failsafe check.
I am glad someone agrees this is a problem. I suggest that the physics.units package be disabled for now as it has serious flaws.

My solution is simply to use positive, real symbolic variables for units. I worry about the conversions myself. For example: `var('J m kg s Pa', positive=True, real=True)`. These behave as proper units and don't do anything mysterious. For unit conversions, I usually just use things like `.subs({J:kg*m**2/s**2})`. You could also use substitution using `.evalf()`.
> I suggest that the physics.units package be disabled for now

That seems a little drastic.

I don't use the units module but the docstring for `convert_to` says:
```
    Convert ``expr`` to the same expression with all of its units and quantities
    represented as factors of ``target_units``, whenever the dimension is compatible.
```
There are examples in the docstring showing that the `target_units` parameter can be a list and is intended to apply only to the relevant dimensions e.g.:
```
In [11]: convert_to(3*meter/second, hour)                                                                                                      
Out[11]: 
10800⋅meter
───────────
    hour
```
If you want a function to convert between strictly between one compound unit and another or otherwise raise an error then that seems reasonable but it probably needs to be a different function (maybe there already is one).
Hi @oscarbenjamin ! Thanks for your leads and additional information provided. I am relatively new to this and have to have a deeper look at the docstring. (Actually, I had a hard time finding the right information. I was mainly using google and did not get far enough.)
I stand by my suggestion. As my first example shows in the initial entry 
for this issue the result from a request that should return the original 
expression unchanged provides a wrong answer. This is exactly equivalent 
to the example you give, except that the particular case is wrong. As 
@schniepp shows there are other cases. This module needs repair and is 
not safely usable unless you know the answer you should get.

I think the convert_to function needs fixing. I would call this a bug. I 
presently do not have time to figure out how to fix it. If somebody does 
that would be great, but if not I think leaving it active makes SymPy's 
quality control look poor.

On 9/26/20 4:07 PM, Oscar Benjamin wrote:
> CAUTION: This email originated from outside of the organization. Do 
> not click links or open attachments unless you recognize the sender 
> and know the content is safe.
>
>     I suggest that the physics.units package be disabled for now
>
> That seems a little drastic.
>
> I don't use the units module but the docstring for |convert_to| says:
>
> |Convert ``expr`` to the same expression with all of its units and 
> quantities represented as factors of ``target_units``, whenever the 
> dimension is compatible. |
>
> There are examples in the docstring showing that the |target_units| 
> parameter can be a list and is intended to apply only to the relevant 
> dimensions e.g.:
>
> |In [11]: convert_to(3*meter/second, hour) Out[11]: 10800⋅meter 
> ─────────── hour |
>
> If you want a function to convert between strictly between one 
> compound unit and another or otherwise raise an error then that seems 
> reasonable but it probably needs to be a different function (maybe 
> there already is one).
>
> —
> You are receiving this because you authored the thread.
> Reply to this email directly, view it on GitHub 
> <https://github.com/sympy/sympy/issues/18368#issuecomment-699548030>, 
> or unsubscribe 
> <https://github.com/notifications/unsubscribe-auth/AAJMTVMMHFKELA3LZMDWCUDSHZJ25ANCNFSM4KILNGEQ>.
>
-- 
Dr. Jonathan H. Gutow
Chemistry Department                                 gutow@uwosh.edu
UW-Oshkosh                                           Office:920-424-1326
800 Algoma Boulevard                                 FAX:920-424-2042
Oshkosh, WI 54901
                 http://www.uwosh.edu/facstaff/gutow/


If the module is usable for anything then people will be using it so we can't just disable it.

In any case I'm sure it would be easier to fix the problem than it would be to disable the module.
Can we then please mark this as a bug, so it will receive some priority.
I've marked it as a bug but that doesn't imply any particular priority. Priority just comes down to what any contributor wants to work on.

I suspect that there are really multiple separate issues here but someone needs to take the time to investigate the causes to find out.
I agree that this is probably an indicator of multiple issues. My quick look at the code suggested there is something odd about the way the basis is handled and that I was not going to find a quick fix. Thus I went back to just treating units as symbols as I do in hand calculations. For teaching, I've concluded that is better anyway.
I also ran into this issue and wanted  to share my experience.  I ran this command and got the following result. 

```
>>> convert_to(5*ohm*2*A**2/cm, watt*m)
1000*10**(18/19)*meter**(13/19)*watt**(13/19)
```

The result is obviously meaningless.  I spent a lot of time trying to figure out what was going on.  I finally figured out the mistake was on my end.  I typed 'watt*m' for the target unit when what I wanted was 'watt/m.'  This is a problem mostly because if the user does not catch their mistake right away they are going to assume the program is not working.
> I suggest that the physics.units package be disabled for now as it has serious flaws.

If we disable the module in the master branch, it will only become available after a new SymPy version release. At that point, we will be bombarded by millions of people complaining about the missing module on Github and Stackoverflow.

Apparently, `physics.units` is one of the most used modules in SymPy. We keep getting lots of complaints even for small changes.
@Upabjojr I understand your reasoning. It still does not address the root problem of something wrong in how the basis set of units is handled. Could somebody at least update the instructions for `convert_to` to clearly warn about how it fails. 

I have other projects, so do not have time to contribute to the units package. Until this is fixed, I will continue to use plain vanilla positive real SymPy variables as units.

Regards
It's curious that this conversation has taken so long, when just 5 minutes of debugging have revealed this simple error:
https://github.com/sympy/sympy/blob/702bceaa0dde32193bfa9456df89eb63153a7538/sympy/physics/units/util.py#L33

`solve_least_squares` finds the solution to the matrix equation. In case no solution is found (like in `convert_to(joule*second, joule)`), it approximates to an inexact solution to the matrix system instead of raising an exception.

Simply changing it to `.solve_least_squares` to `.solve` should fix this issue.
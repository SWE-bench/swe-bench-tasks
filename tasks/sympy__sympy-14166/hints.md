What I was saying was that we should replace the calligraphy O with a normal O, not the other way around. 
Oh sorry, @asmeurer I didn't see your comment. Should I close #14164?
I also read the issue wrong. But I just checked the master branch:
```
>>> pprint(series(cos(x), x, pi, 3))
            2
     (x - π)     ⎛       3       ⎞
-1 + ──────── + O⎝(x - π) ; x → π⎠
        2
```
The `O` here is ordinary O only, [see](https://github.com/sympy/sympy/blob/2c0a3a103baa547de12e332382d44ee3733d485f/sympy/printing/pretty/pretty.py#L1278).
@jashan498 The issue is about LaTeX printer, which uses calligraphic O
```
It works for me, but I have 0.9.2.  So something in py must have broken it.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1741#c1
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
It's kinda written on the tin that this would break with any new release. Surely, a
module named '__' is meant to be private!

NB: I get the same traceback as Vinzent with version 1.0.0.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1741#c2
Original author: https://code.google.com/u/101272611947379421629/

```
We should use the new plug-in architecture, if possible. Maybe we should talk to
upstream about possible abuses for benchmarking.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1741#c3
Original author: https://code.google.com/u/Vinzent.Steinberg@gmail.com/

```
Is there a reasonable work-around for this? I'm facing the same problem...
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1741#c4
Original author: https://code.google.com/u/christian.muise/

```
Basically I think we have to rewrite it. It should be much easier with the new plugin 
infrastructure. Or we even use our own test runner. We just need someone to do it. The 
easiest work-around would be to use mpmath's test runner, that also prints the time 
taken: http://code.google.com/p/mpmath/source/browse/trunk/mpmath/tests/runtests.py Much simpler than sympy's runner and thus easier to adapt.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1741#c5
Original author: https://code.google.com/u/Vinzent.Steinberg@gmail.com/

```
**Labels:** Milestone-Release0.7.0  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1741#c6
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
Is it possible to adapt IPython's timeit to do benchmarking?

**Cc:** elliso...@gmail.com  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1741#c7
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
See timeutils.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1741#c8
Original author: https://code.google.com/u/101069955704897915480/

```
This is non-trivial to fix, so unless someone wants to do it soon, I am going to postpone the release milestone.

**Labels:** -Milestone-Release0.7.0 Milestone-Release0.7.1  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1741#c9
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Blocking:** 5641  

```

Referenced issues: #5641
Original comment: http://code.google.com/p/sympy/issues/detail?id=1741#c10
Original author: https://code.google.com/u/101272611947379421629/

```
I don't think anybody uses it any more, so I think we should just consider it broken and not let that hold back other changes (e.g. issue 5641 ). 

Also, I think that we should just remove all the timeit_* microbenchmarks: there's no guarantee that they're actually relevant and they're more likely than not to push us towards premature optimisation whenever we pay attention to them.

**Labels:** Testing  

```

Referenced issues: #5641
Original comment: http://code.google.com/p/sympy/issues/detail?id=1741#c11
Original author: https://code.google.com/u/101272611947379421629/

```
I'd like to do a small 0.7.1 release with IPython 0.11 support, so these will be postponed until 0.7.2.

**Labels:** Milestone-Release0.7.2  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1741#c12
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
What does PyPy use for their extensive benchmarking ( http://speed.pypy.org/)?
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1741#c13
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
Apparently something called Codespeed: https://github.com/tobami/codespeed/wiki/ I think if we want to work on benchmarking, we need to first think up appropriate benchmarks, independent of any test runner. You said on the PyPy issue that we have various benchmarks, but they probably aren't relevant anymore. So, first order of business should be that, and then it will be easier to switch to whatever benchmarking solution we decide on.

I'll look into this a bit more when I get the chance.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1741#c14
Original author: https://code.google.com/u/108713607268198052411/

```
This is hardly a release blocker, but I'm going to raise the priority to high because we really should have some kind of benchmarking.

**Labels:** -Priority-Medium -Milestone-Release0.7.2 Priority-High  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1741#c15
Original author: https://code.google.com/u/108713607268198052411/

```
**Status:** Valid  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1741#c16
Original author: https://code.google.com/u/asmeurer@gmail.com/

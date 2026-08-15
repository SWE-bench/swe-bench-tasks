I noticed that if I remove the extra assumptions (i.e. use `sp.Symbol('x')` instead of `sp.Symbol('x', real=True, nonzero=True)`), then it works as expected.
```
import sympy as sp

def test():
    x1 = sp.Symbol('x', real=True)
    x2 = sp.Symbol('x', real=True)

    assert (hash(x1) == hash(x2) and sp.simplify(x1 - x2) == 0)
    
    import pickle
    x2_pickled = pickle.dumps(x2)
    x2_unpickled = pickle.loads(x2_pickled)

    assert (hash(x1) == hash(x2_unpickled) and sp.simplify(x1 - x2_unpickled) == 0)


if __name__ == '__main__':
    test()
```

Here is an example of a minimal unit test which reveals the bug and indeed shows that the issue is with the pickling.
Without `real=True` it works so I guess there is an issue with pickling symbols with non-default assumptions.
It seems that multiprocessing somehow finds a global symbol (at least on my system). I can see that by appending
```
    from sympy.functions.combinatorial.numbers import _sym
    for s in symbols:
        print(s == _sym)
```
to the code in https://github.com/sympy/sympy/issues/21121#issue-834785397.
I'm not sure I've completely figured out how Symbol works. The problem seems to be that the `_mhash` gets set before the assumptions are assigned by `__setstate__` when unpickling. That means that the `_mhash` is incorrect.

This seems to fix it (using `__getnewargs_ex__` to pass all args up front so that hash is correct from the start):
```diff
diff --git a/sympy/core/basic.py b/sympy/core/basic.py
index dce161a2b2..a9bf432a9e 100644
--- a/sympy/core/basic.py
+++ b/sympy/core/basic.py
@@ -121,20 +121,6 @@ def __new__(cls, *args):
     def copy(self):
         return self.func(*self.args)
 
-    def __reduce_ex__(self, proto):
-        """ Pickling support."""
-        return type(self), self.__getnewargs__(), self.__getstate__()
-
-    def __getnewargs__(self):
-        return self.args
-
-    def __getstate__(self):
-        return {}
-
-    def __setstate__(self, state):
-        for k, v in state.items():
-            setattr(self, k, v)
-
     def __hash__(self):
         # hash cannot be cached using cache_it because infinite recurrence
         # occurs as hash is needed for setting cache dictionary keys
diff --git a/sympy/core/symbol.py b/sympy/core/symbol.py
index 41b3c10672..56f9b3e6b8 100644
--- a/sympy/core/symbol.py
+++ b/sympy/core/symbol.py
@@ -300,11 +300,8 @@ def __new_stage2__(cls, name, **assumptions):
     __xnew_cached_ = staticmethod(
         cacheit(__new_stage2__))   # symbols are always cached
 
-    def __getnewargs__(self):
-        return (self.name,)
-
-    def __getstate__(self):
-        return {'_assumptions': self._assumptions}
+    def __getnewargs_ex__(self):
+        return ((self.name,), self.assumptions0)
 
     def _hashable_content(self):
         # Note: user-specified assumptions not hashed, just derived ones
```
It seems to me that there is a cache problem. Multiprocessing will modify a global symbol in sympy.functions.combinatorial.numbers. This code
```
import multiprocessing as mp
import sympy as sp
from sympy.functions.combinatorial.numbers import _sym

print(_sym.assumptions0)

VAR_X = sp.Symbol('x', real=True, nonzero=True)

def process():
    return sp.Symbol('x', real=True, nonzero=True)

if __name__ == '__main__':
    a1 = sp.Symbol('a', real=True, nonzero=True)
    a2 = sp.Symbol('a', real=True, nonzero=True)
    print(a1, a2, a1 == a2, a1 - a2, '\n')

    pool = mp.Pool(4)
    jobs = []
    for _ in range(5):
        jobs.append(pool.apply_async(process))
    symbols = []
    for job in jobs:
        symbols.append(job.get())
    pool.close()

    print(_sym.assumptions0)
```
gives this output on my system
```
{'commutative': True}
a a True 0 

{'real': True, 'finite': True, 'imaginary': False, 'extended_real': True, 'commutative': True, 'complex': True, 'hermitian': True, 'infinite': False, 'nonzero': True, 'zero': False, 'extended_nonzero': True}
```
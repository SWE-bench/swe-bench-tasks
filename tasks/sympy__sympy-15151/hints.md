I guess the problem is that it's not valid LaTeX. We should at the very least wrap the indexedbase in `{}` in the printer so that it would print `{x_{1}}_{i}`. 
Hello @majidaldo @asmeurer I have basic knowledge of Sympy and Python. I am interested in fixing this bug and I tried to reciprocate  @majidaldo  code.
The output I received was :-
> x1[i]

@asmeurer Could you please help me in understanding the issue so that I can try to fix it.

Regards
Ayushman Koul
You need to run it in the notebook to get the LaTeX. Or you can just check `latex(Indexed('x1', Symbol('i')))`. 
Thank You @asmeurer for responding.The problem we are getting as mentioned by @majidaldo the expected output in latex should have been  `x_{1,i}` but we are getting `x_{1}_{i}` which is not valid.Well do we need to alter the code in Latex file inside the printing directory to overcome this issue or any other file ?
Please help me in resolving this issue.

Regards
Ayushman Koul
I would focus on getting it to output `{x_{1}}_{i}`. Getting `x_{1,i}` is more difficult, and I'm not even sure if it should do that anyway. 
Hi, I was working on this before I realized that @ayushmankoul  was working on this as well. I came up with the following  change:
```diff
+++ b/sympy/printing/latex.py
@@ -607,7 +607,10 @@ def _print_BasisDependent(self, expr):
         return outstr
 
     def _print_Indexed(self, expr):
-        tex = self._print(expr.base)+'_{%s}' % ','.join(
+        tex_base = self._print(expr.base)
+        if re.search(r'_\{.\}$', tex_base) is not None:
+            tex_base = '{'+tex_base+'}'
+        tex = tex_base+'_{%s}' % ','.join(
             map(self._print, expr.indices))
         return tex
```
Maybe this is of any help to you @ayushmankoul 
Cheers.
Thank You @bPhysicist for sharing the code and one would get the desired output `{x_{1}}_{i}` which was suggested by @asmeurer  .May I know if you can point me to the test cases which checks for the validity of generated latex in case one would have to write a text case for this scenario ?

```
from sympy import*
from sympy import init_printing;init_printing()
i=symbols('i')
print Indexed('x1',i)     
print latex(Indexed('x1',i))
```

Output:-
```
x1[i]
{x_{1}}_{i}
```
This is the file which contains latex tests:
https://github.com/sympy/sympy/blob/master/sympy/printing/tests/test_latex.py
I would omit the regex and just always wrap the base in {}
@asmeurer @bPhysicist  I tried to alter the code to  wrap up the base always in {} which is as following:
```
 def _print_Indexed(self, expr):
-       tex = self._print(expr.base)+'_{%s}' % ','.join(
+       tex_base = self._print(expr.base)
-       if re.search(r'_\{.\}$', tex_base) is not None:
+       tex_base = '{'+tex_base+'}'
+       tex = tex_base+'_{%s}' % ','.join(
               map(self._print, expr.indices))
        return tex

```
But the test cases failed due to following error:
```
Traceback (most recent call last):
  File "e:\sympy\sympy\printing\tests\test_latex.py", line 527, in test_latex_indexed
    or symbol_latex.split() == indexed_latex.split()[::-1]
AssertionError
```
On investigating the cause of assertion error I found out that on changing the code,the value of `indexed_latex=\\overline{{\\Psi}_{0}} {\\Psi}_{0}` had addition of {}around Psi ,whereas the value of `symbol_latex=\\Psi_{0} \\overline{\\Psi_{0}}` was unchanged which led to assertion error.In order to avoid this error we can alter test cases for latex printing.

@bPhysicist Have you made any pull request for this issue ? If not,then would you mind if I create one for this ? I am just a student who is trying to understand open source contribution.
@ayushmankoul no I have not created one - sure go ahead and open one
I guess the test should be changed. Probably in the future we can try to optimize the latex printer so that redundant braces are removed, but that's a much harder problem for another issue. 
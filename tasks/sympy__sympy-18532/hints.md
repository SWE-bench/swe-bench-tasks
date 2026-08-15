The docstring should also be updated. 

Hi, can i work on this?

Sure. Did you read https://github.com/sympy/sympy/wiki/Introduction-to-contributing? 

How should I remove .args? Should I try to remove ._args from object instance or add a new attribute to class Atom(), is_leave. Which when assigned as false, will raise attribute error on .args. Or if creating a new object, what attributes should it have?

I think you're misunderstanding the issue. The issue is not to remove .args. Indeed, every SymPy object should have .args in order to be valid. 

The issue is that the `atoms()` method currently uses `x.is_Atom` to check for "atomic" expressions (expressions with no subexpressions), but it really should be checking `not x.args`. It should be a simple one-line fix to the `atoms` function definition, but a new test should be added, and the full test suite run to make sure it doesn't break anything (`./bin/test` from the sympy directory). 

Okay. But, Basic() also return .args to be null. So will not that also appear in the result of .atoms()?

Yes, that's an example of an object with no args but that isn't a subclass of Atom. `atoms` should return that, because it's a leaf in the expression tree. 

Okay, but if I am understanding you correct, won't this test fail?
https://github.com/sympy/sympy/blob/master/sympy/core/tests/test_basic.py#L73

Yes, it would need to be changed. This is a slight redefinition of what `atoms` means (although hopefully not enough of a breaking behavior to require deprecation). 

Can you look over it once and look if it is okay?
https://github.com/sympy/sympy/pull/10246

@asmeurer 
When I ran the full suite of tests, sympy/vector/tests/test_field_functions.py failed on all the tests. 

```
     Original-
            if not (types or expr.args):
                result.add(expr)

     Case 1-     
            if not types:
                if isinstance(expr, Atom):
                    result.add(expr)

     Case 2-
            if not (types or expr.args):
                if isinstance(expr, Atom):
                    result.add(expr)
```

I saw that fails even on the second case. Then I saw the items that case1 had but case2 did not. Which were all either `C.z <class 'sympy.vector.scalar.BaseScalar'>` or `C.k <class 'sympy.vector.vector.BaseVector'>`. 

Elements of the class sympy.vector.scaler.BaseScalar or class sympy.vector.vector.BaseVector were earlier considered but not now, as they were Atom but had arguments. So what should we do?

I want to fix this if no one is working on it.

I am unable to figure out why 'Atom' has been assigned to 'types' . We can add the result while checking for the types and if there are no types then we can simply add x.args to the result. That way it will return null and we will not be having subclasses of Atom.

ping @asmeurer 

@darkcoderrises I have some fixes at https://github.com/sympy/sympy/pull/10084 which might make your issues go away. Once that is merged you should try merging your branch into master and see if it fixes the problems. 

ok

I merged the pull requests, and now the tests are passing. What should be my next step.
https://github.com/sympy/sympy/pull/10246

I am working on this issue
Hi @moorepants ! I want to work on this issue .
Go for it!
@moorepants Any kind of help will be appreciated.I'm new to this organization.
Start here: https://github.com/sympy/sympy/wiki/introduction-to-contributing

Read the materials, setup your dev environment, and do the tutorial.
@moorepants I've read the materials.
Coming back to the issue tell me about the changes need to be done and point me to the files to be worked with.
Here is the associated code: https://github.com/sympy/sympy/blob/master/sympy/integrals/integrals.py#L993

I suggest seeing if the reviewers would accept a deprecation so that we can change the behavior of `as_sum` but if not you'll need to create a new method. It would also be worth determining if the `Sum` object has duplicate code for the expansions in it's `doit()` method.
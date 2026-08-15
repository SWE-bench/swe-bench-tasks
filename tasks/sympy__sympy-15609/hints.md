Related to https://github.com/sympy/sympy/issues/15059
It's pretty simple to solve, `_print_MatrixElement` of `LatexPrinter` is not calling `self._print` on the indices.
I'd like to work on this. When adding a test, should I expand `test_MatrixElement_printing` or add `test_issue_15595` just for this issue? Or both?
The correct one should be `\sum_{i_{1}=0}^{k - 1} M_{i, i_1} N_{i_1, j}`.
Is that right?
Tests can be put everywhere. I'd prefer to have them next to the other ones.
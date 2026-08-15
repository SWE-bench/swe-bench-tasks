Hello, I am trying to get myself familiar with the code base and I would like to take a look at this issue. Could you elaborate a little more on what is expected output and the problem?
@iam-abbas , the correct output should be `6 \cdot 1/2`.
The correct output should be: 
```ruby
>>> latex(Mul(6, S.Half, evaluate=False))
'6 \\cdot  \\frac{1}{2}'
```

This is an easy fix @iam-abbas , you probably need to make changes here:
https://github.com/sympy/sympy/blob/2346054bb4888ef7eec2f6dad6c3dd52bf1fe927/sympy/printing/latex.py#L521
Yes, the problem is here: `if _between_two_numbers_p[0].search(last_term_tex) and _between_two_numbers_p[1].match(term_tex):`

Don't understand why regex is used instead of testing whether it is a number.
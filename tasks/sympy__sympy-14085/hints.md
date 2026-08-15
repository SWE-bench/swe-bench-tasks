```
Actually, "α" is garbage and we shouldn't do anything with it: that's a bytestream
containing whatever value the system's encoding gives to the unicode character alpha.
That the interpreter allows such nonsense is a Python 2.* bug. Python 3.* is much
more sensible (recall that a Python 3.* string is Python 2.*'s unicode, while Python
3.*'s bytes is Python 2.*'s string):

Python 3.1.1+ ( r311 :74480, Nov  2 2009, 14:49:22) 
[GCC 4.4.1] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> "α"
'α'
>>> b"α"
  File "<stdin>", line 1
SyntaxError: bytes can only contain ASCII literal characters.

For comparison:

Python 2.6.4 ( r264 :75706, Nov  2 2009, 14:38:03) 
[GCC 4.4.1] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> "α"
'\xce\xb1'
>>> u"α"
u'\u03b1'
>>> print u"α"
α

On the other hand, u"α" is a sensible value and sympify should definitely do
something with it, but doesn't:

In [56]: sympify(u"α")
---------------------------------------------------------------------------
UnicodeEncodeError                        Traceback (most recent call last)

/media/sda2/Boulot/Projets/sympy-git/<ipython console> in <module>()

/media/sda2/Boulot/Projets/sympy-git/sympy/core/sympify.pyc in sympify(a, locals,
convert_xor)
    109             # and try to parse it. If it fails, then we have no luck and

    110             # return an exception

--> 111             a = str(a)
    112 
    113         if convert_xor:

UnicodeEncodeError: 'ascii' codec can't encode characters in position 0-1: ordinal
not in range(128)

**Summary:** sympify(u"α") does not work  
**Labels:** -Priority-Medium Priority-High Milestone-Release0.7.0  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1763#c1
Original author: https://code.google.com/u/101272611947379421629/

```
In my "code-refactor-3" branch, I bypass the encoding problem and get the same error
as in the initial comment:

In [1]: sympify(u"α")
---------------------------------------------------------------------------
SympifyError                              Traceback (most recent call last)

/media/sda2/Boulot/Projets/sympy-git/<ipython console> in <module>()

/media/sda2/Boulot/Projets/sympy-git/sympy/core/sympify.py in sympify(a, locals,
convert_xor, strict)
    123 
    124     import ast_parser
--> 125     return ast_parser.parse_expr(a, locals)
    126 
    127 def _sympify(a):

/media/sda2/Boulot/Projets/sympy-git/sympy/core/ast_parser.pyc in parse_expr(s,
local_dict)
     88             a = parse(s.strip(), mode="eval")
     89         except SyntaxError:
---> 90             raise SympifyError("Cannot parse.")
     91         a = Transform(local_dict, global_dict).visit(a)
     92         e = compile(a, "<string>", "eval")

SympifyError: SympifyError: 'Cannot parse.'


The fundamental problem is that ast_parser can only handle valid Python2 identifiers,
which are limited to basic ASCII characters. Solving this seems very difficult. OTOH,
the good news is that Python3  has solved the problem for us. 
I'd suggest we postpone this until either:
* we switch to Python3
* or someone decides to do a complete overhaul of the parser.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1763#c2
Original author: https://code.google.com/u/101272611947379421629/

```
It isn't that important, and there is no point in refactoring the parser when it will not be a problem in Python 3, 
so I vote to postpone to Python 3.  Likely we will go through a period of supporting both, so lets just make sure 
that it works in Python 3 whenever we have a branch for it.  

So variable names can be unicode in Python 3?  I didn't know that.

**Labels:** -Priority-High -Milestone-Release0.7.0 Priority-Low Milestone-Release0.8.0  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1763#c3
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
There are several motivations to write an own parser: issue 3970 , issue 4075 and issue 3159 .
```

Referenced issues: #3970, #4075, #3159
Original comment: http://code.google.com/p/sympy/issues/detail?id=1763#c4
Original author: https://code.google.com/u/Vinzent.Steinberg@gmail.com/

```
We now support Python 3, but there's still an error:

>>> S("α")
Traceback (most recent call last):
  File "<console>", line 1, in <module>
  File "/home/vperic/devel/sympy/sympy-py3k/sympy/core/sympify.py", line 155, in sympify
    expr = parse_expr(a, locals or {}, rational, convert_xor)
  File "/home/vperic/devel/sympy/sympy-py3k/sympy/parsing/sympy_parser.py", line 112, in parse_expr
    expr = eval(code, global_dict, local_dict) # take local objects in preference
  File "<string>", line 1, in <module>
NameError: name 'α' is not defined

(dropping the milestone because it's just annoying :) )

**Labels:** -Milestone-Release0.8.0 Python3  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1763#c5
Original author: https://code.google.com/u/108713607268198052411/

```
I think we do have our own parser now.  If I'm not mistaken, we could just add a token that converts a string of unicode characters to symbols.  Or maybe we should just limit it to things greek characters.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1763#c6
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Labels:** Parsing  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1763#c7
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Status:** Valid  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=1763#c8
Original author: https://code.google.com/u/asmeurer@gmail.com/

If it's still open I would like to work on this.
Looks like it still doesn't work. 
But there may already be a fix at https://github.com/sympy/sympy/pull/8334
@asmeurer  I feel this is not fixed  till now, please have a look below, I would like to solve this can you guide me

```
In [1]: from sympy import *

In [2]: sympify(u"α")
---------------------------------------------------------------------------
SympifyError                              Traceback (most recent call last)
<ipython-input-2-cf317bba09e1> in <module>()
----> 1 sympify(u"α")

/home/saiharsh/sympy/sympy/core/sympify.pyc in sympify(a, locals, convert_xor, strict, rational, evaluate)
    329         expr = parse_expr(a, local_dict=locals, transformations=transformations, evaluate=evaluate)
    330     except (TokenError, SyntaxError) as exc:
--> 331         raise SympifyError('could not parse %r' % a, exc)
    332 
    333     return expr

SympifyError: Sympify of expression 'could not parse u'\u03b1'' failed, because of exception being raised:
SyntaxError: invalid syntax (<string>, line 1)
```

We just need to update our copy of the Python tokenizer (in sympy_tokenize.py) to be compatible with Python 3. 

I forget the reason why we have a copy of it instead of just using the version from the standard library. Can someone figure out the difference between our tokenizer and the Python 2 tokenizer? 
It looks like our tokenizer is there to support two extensions:

- factorial (`x!`)
- repeated decimals (`1.[2]`)

I would reconsider for both of these if they could just be done with a preparser, so we can just use the standard tokenizer. That would also allow disabling these things, which currently isn't possible. We'd have to do some manual tokenization to make sure we don't preparse the inside of a string, though.

If we don't go this route, we need to update the tokenizer to be based on Python 3's grammar. This should be a simple matter of copying the Python 3 tokenize module and re-applying our modifications to it. 
Actually to properly handle ! we have to do a proper tokenization. Consider more complicated expressions like `(1 + 2)!`. 

Perhaps it is possible to just tokenize the expression with `!` and postprocess. It seems to produce an ERRORTOKEN and not stop the tokenization.

```py
>>> import tokenize
>>> import io
>>> for i in tokenize.tokenize(io.BytesIO(b'(1 + 2)! + 1').readline):
...     print(i)
TokenInfo(type=59 (BACKQUOTE), string='utf-8', start=(0, 0), end=(0, 0), line='')
TokenInfo(type=53 (OP), string='(', start=(1, 0), end=(1, 1), line='(1 + 2)! + 1')
TokenInfo(type=2 (NUMBER), string='1', start=(1, 1), end=(1, 2), line='(1 + 2)! + 1')
TokenInfo(type=53 (OP), string='+', start=(1, 3), end=(1, 4), line='(1 + 2)! + 1')
TokenInfo(type=2 (NUMBER), string='2', start=(1, 5), end=(1, 6), line='(1 + 2)! + 1')
TokenInfo(type=53 (OP), string=')', start=(1, 6), end=(1, 7), line='(1 + 2)! + 1')
TokenInfo(type=56 (ERRORTOKEN), string='!', start=(1, 7), end=(1, 8), line='(1 + 2)! + 1')
TokenInfo(type=53 (OP), string='+', start=(1, 9), end=(1, 10), line='(1 + 2)! + 1')
TokenInfo(type=2 (NUMBER), string='1', start=(1, 11), end=(1, 12), line='(1 + 2)! + 1')
TokenInfo(type=0 (ENDMARKER), string='', start=(2, 0), end=(2, 0), line='')
```

For `0.[1]`, it's actually valid Python (it's an indexing of a float literal). So this can be post processed as well, probably at the AST level. We only allow this syntax for numeric values, no symbolic, so this isn't an issue. 
Our transformations are currently done only with the tokenization, not the ast (though that [could change](https://github.com/sympy/sympy/issues/10805)). Regardless, handling `0.[1]` is trivial to do with the standard tokenization. 
By the way you have to use `tokenize.generate_tokens`, not `tokenize.tokenize`, because in Python 2 `tokenize.tokenize` just prints the tokens instead of returning them. 
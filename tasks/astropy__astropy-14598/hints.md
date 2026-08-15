Hello, I would like to be assigned to this issue if possible. Thank you.
Hi @ashtonw3,
We don't usually assign people to issues, mentioning here that you want to work on it is enough.
But on this specific issue I already have a fix and will open a PR soon, I was going to do that yesterday but I found another related issue that needed an additional fix:

First issue, the quote at the end of the line is lost:
```
In [5]: fits.Card.fromstring(fits.Card("FOO", "x"*100 + "''", "comment").image).value
Out[5]: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'"
```

Additional issue, a string after the quotes is lost if there is a space in between:
```
In [7]: fits.Card.fromstring(fits.Card("FOO", "x"*100 + "'' aaa", "comment").image).value
Out[7]: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'"
```
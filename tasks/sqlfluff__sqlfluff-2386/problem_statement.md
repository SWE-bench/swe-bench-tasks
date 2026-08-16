Double backticks in Lint description
![image](https://user-images.githubusercontent.com/80432516/150420352-57452c80-ad25-423b-8251-645e541579ad.png)
(n.b. this affects a lot more rules than L051)

This was introduced in #2234 in which docstrings such as
```
`INNER JOIN` must be fully qualified.
```
were replaced with 
```
``INNER JOIN`` must be fully qualified.
```
so that they appear as code blocks in Sphinx for docs.
![image](https://user-images.githubusercontent.com/80432516/150420294-eb9d3127-db1d-457c-a637-d614e0267277.png)

However, our rules will use the first line of these docstrings in the event that no `description` is provided to the lint results.

This doesn't look great on the CLI so we should fix this. As far as I'm aware there are two approaches for this:
1. Pass a `description` to all the `LintResult`s.
2. Update the code that gets the default description from the docstring to do something like, replace the double backticks with a single one, or remove them, or do something clever like make them bold for the CLI and remove them for non-CLI.

My strong preference is number 2, but I'm open to discussion as to how exactly we do this 😄 

@barrywhart @tunetheweb 

I would disagree. 2 arguments:

`There should be one-- and preferably only one --obvious way to do it.` as says https://www.python.org/dev/peps/pep-0020/

it makes documentation harder.
Raise an exception to tell the user to use `scalars` when `scalar` is used as a keyword arg. 
Okay, I'm convinced. 

We may want to do some keyword refactoring and not just allow an endless dict of `**kwargs` to be passed to `add_mesh`. For example, you can pass all types of typos and not have an error thrown:

```py
import pyvista as pv
p = pv.Plotter()
p.add_mesh(pv.Cube(), my_crazy_argument="foooooooo")
p.show()
```

There are several places in the API where this can happen that will need to be refactored 
What we could do is pop out the allowed aliases like `rng` and then raise an exception if the `kwargs` dict is not empty that might say something like:

> "[list of arguments still in the kwargs] are not valid keyword arguments."
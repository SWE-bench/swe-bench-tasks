Looks like a conscious design choice. Not sure if there is an easy way to change it. Ideas welcome!

https://github.com/astropy/astropy/blob/b3b8295c4b0478558bd0e4c6ec28bf16b90880b8/astropy/io/votable/tree.py#L2422-L2429
It maybe conscious, or just history, either case I think it maybe also responsible for the occasional confusion and questions we get at the Navo workshops about votable vs table.

I meant to cc @tomdonaldson. 
Well, maybe we can patch the start of the returned string, like replacing `<Table` with `<VOTable`, if that isn't too hacky.
Yes, I think that would be an ideal solution.
Note to self: To grab VOTable without internet access, can also use this:

```python
from astropy.io.votable.table import parse
from astropy.utils.data import get_pkg_data_filename
fn = get_pkg_data_filename("data/regression.xml", package="astropy.io.votable.tests")
t = parse(fn).get_first_table()
```

And looks like only `repr` is affected.
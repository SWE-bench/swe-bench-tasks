Hi. I am a new contributor and was wondering if this was still open for contribution? I would like to look into this if possible. 
Hello! The issue is still open, so feel free. 😸 
@JefftheCloudDog  that would be great! No one else is currently working on this feature request. If you need any help or have any questions I am happy to help. You can post here, or in the Astropy Slack cosmology channel. We also have documentation to assist in contributing at https://www.astropy.org/contribute.html#contribute-code-or-docs.
From my understanding of the request description, the high-level steps should look as such:

1. get a QTable object from the `cosmology.io.table.to_table()` function, which returns a QTable
2. format to MathJax 
3. call `QTable.write()` to write
4. The registration should look like this: `readwrite_registry.register_writer("ascii.html", Cosmology, write_table)`

From the steps and observing some examples from Cosmology/io, this `write_table()` should look very similar to `write_ecsv()` from Cosmology/io/ecsv.py

Am I correct in understanding so far? 
@JefftheCloudDog, correct! Looks like a great plan for implementation.

In #12983 we are working on the backend which should make the column naming easier, so each Parameter can hold its mathjax representation.
In the meantime it might be easiest to just have a `dict` of parameter name -> mathjax name.

Ah, I see. The format input is just a dict that has mathjax (or some other type) representation as values which should be an optional parameter. 

I'm looking through the example of def_unit, and looks like a new type of unit is defined with the format dict. 
Should `write_table()` function the same way? Are we creating a new Cosmology or QTable object for formatting? 

I suppose we are essentially using [`Table.write()`](https://docs.astropy.org/en/stable/api/astropy.table.Table.html#astropy.table.Table.write) since a QTable object is mostly identical to a Table object. 
When https://github.com/astropy/astropy/pull/12983 is merged then each parameter will hold its mathjax representation.
e.g. for latex.

```python
class FLRW(Cosmology):
    H0 = Parameter(..., format={"latex": r"$H_0$"})
```

So then the columns of the ``FLRW`` -> ``QTable`` can be renamed like (note this is a quick and dirty implementation)

```python
tbl = to_table(cosmo, ...)
for name in cosmo.__parameters__:
    param = getattr(cosmo.__class__, name)
    new_name = param.get_format_name('latex')
    tbl.rename_column(name, new_name)
```

However, https://github.com/astropy/astropy/pull/12983 is not yet merged, so the whole mathjax format can just be one central dictionary:

```python
mathjax_formats = dict(H0=..., Ode0=...)
```

Making it

```python
tbl = to_table(cosmo, ...)
for name in cosmo.__parameters__:
    new_name = mathjax_formats.get(name, name)  # fallback if not in formats
    tbl.rename_column(name, new_name)
```

Anyway, that's just what I was suggesting as a workaround until https://github.com/astropy/astropy/pull/12983 is in.
Ok, I see. Since this deals with i/o, the new code should go to astropy\cosmology\table.py? 

I see that there is already a line for `convert_registry.register_writer("astropy.table", Cosmology, to_table)`, so I was not sure if there should be a different file to register the new method.
> I see that there is already a line for convert_registry.register_writer("astropy.table", Cosmology, to_table), so I was not sure if there should be a different file to register the new method.

Yes, this should probably have a new file ``astropy/cosmology/io/html.py``.
I am writing tests now and it looks like writing fails with the following errors. I am not quite sure why these errors are appearing. I have been trying to understand why the error is occurring, since ascii.html is a built-in HTML table writer, but I am struggling a little. Can someone provide some support?

I based the first test on cosmology\io\tests\test_ecsv.py. Seems like the test is just failing on write.

```
fp = tmp_path / "test_to_html_table_bad_index.html"
write(file=fp)
```


error: 
```
self = <astropy.cosmology.io.tests.test_html.TestReadWriteHTML object at 0x00000175CE162F70>, read = <function ReadWriteDirectTestBase.read.<locals>.use_read at 0x00000175CE2F3280>
write = <function ReadWriteDirectTestBase.write.<locals>.use_write at 0x00000175CE4B9A60>, tmp_path = WindowsPath('C:/Users/jeffr/AppData/Local/Temp/pytest-of-jeffr/pytest-34/test_to_html_table_bad_index_c7')

    def test_to_html_table_bad_index(self, read, write, tmp_path):
        """Test if argument ``index`` is incorrect"""
        fp = tmp_path / "test_to_html_table_bad_index.html"

>       write(file=fp, format="ascii.html")

astropy\cosmology\io\tests\test_html.py:30:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
astropy\cosmology\io\tests\base.py:196: in use_write
    return self.functions["write"](cosmo, *args, **kwargs)
astropy\cosmology\io\html.py:86: in write_table
    table.write(file, overwrite=overwrite, **kwargs)
astropy\table\connect.py:129: in __call__
    self.registry.write(instance, *args, **kwargs)
astropy\io\registry\core.py:354: in write
    return writer(data, *args, **kwargs)
astropy\io\ascii\connect.py:26: in io_write
    return write(table, filename, **kwargs)
astropy\io\ascii\ui.py:840: in write
    lines = writer.write(table)
astropy\io\ascii\html.py:431: in write
    new_col = Column([el[i] for el in col])
astropy\table\column.py:1076: in __new__
    self = super().__new__(
astropy\table\column.py:434: in __new__
    self_data = np.array(data, dtype=dtype, copy=copy)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <Quantity 0. eV>

    def __float__(self):
        try:
            return float(self.to_value(dimensionless_unscaled))
        except (UnitsError, TypeError):
>           raise TypeError('only dimensionless scalar quantities can be '
                            'converted to Python scalars')
E           TypeError: only dimensionless scalar quantities can be converted to Python scalars

astropy\units\quantity.py:1250: TypeError
```
@JefftheCloudDog Thanks for dropping in the test output. The best way for me to help will be to see the code. To do that, it would be great if you opened a Pull Request with your code. Don't worry that the PR is not in it's final state, you can open it as Draft. Thanks!

See https://docs.astropy.org/en/latest/development/workflow/development_workflow.html if you are unsure how to make a Pull Request.
Thanks for the response! I created a [draft pull request ](https://github.com/astropy/astropy/pull/13075) for this issue. I did try to adhere to the instructions, but since this is my first contribution, there might be some mistakes. Please let me know if there are any issues. 
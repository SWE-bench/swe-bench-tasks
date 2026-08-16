This line in cli.py seems largely to blame -- it somewhat conflates output _format_ with writing to a file or not.
```
non_human_output = (format != FormatType.human.value) or (write_output is not None)
```

It will require some care to fix this. Simply removing `or (write_output is not None)` didn't seem to fix it.

As a workaround until this is fixed, you may be able to use output redirection, e.g.
```
python -m sqlfluff lint --config=config/sql-lint.cfg > test.txt
```


Your workaround does work for me, thank you. Seeing as this solution is only a workaround I imagine closing the ticket is not preferable.
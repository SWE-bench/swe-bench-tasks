Fatal templating error with Jinja templater. Tracer produces odd results.
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

Issue found while assessing an Airflow project.

The smallest query I can make which triggers the issue is: 
```sql
SELECT
	{% block table_name %}a{% endblock %}.b
FROM d.{{ self.table_name() }}
```

When running this query through `lint` I get an `AssertionError`, or if running on the more friendly error message PR (#3433) I get: `WARNING    Length of templated file mismatch with final slice: 21 != 19.`.

### Expected Behaviour

This query should slice properly and probably eventually give a jinja error that the required variables are undefined.

### Observed Behaviour

I've dug a little into the error and the sliced file being produced is:

```python
[
    TemplatedFileSlice(slice_type='literal', source_slice=slice(0, 8, None), templated_slice=slice(0, 8, None)),
    TemplatedFileSlice(slice_type='block_start', source_slice=slice(8, 30, None), templated_slice=slice(8, 8, None)),
    TemplatedFileSlice(slice_type='literal', source_slice=slice(30, 31, None), templated_slice=slice(8, 9, None)),
    TemplatedFileSlice(slice_type='block_end', source_slice=slice(31, 45, None), templated_slice=slice(9, 9, None)),
    TemplatedFileSlice(slice_type='literal', source_slice=slice(45, 55, None), templated_slice=slice(9, 19, None)),
    TemplatedFileSlice(slice_type='templated', source_slice=slice(55, 78, None), templated_slice=slice(19, 19, None)),
    TemplatedFileSlice(slice_type='literal', source_slice=slice(78, 79, None), templated_slice=slice(19, 19, None))
]
```

The issue is that while the `source_slice` looks correct for the slices, almost all of the `templated_slices` values have zero length, and importantly the last one doesn't end at position 21.

The rendered file is `SELECT\n\ta.b\nFROM d.a\n` (I've included the escape chars) which is indeed 21 chars long.

@barrywhart I might need your help to work out what's going on with the Jinja tracer here.

### How to reproduce

Run provided query, `main` branch. Set to the `jinja` templater.

### Dialect

dialect is set to `snowflake`, but I don't think we're getting far enough for that to make a difference.

### Version

`main` branch commit `cb6357c540d2d968f766f3a7a4fa16f231cb80e4` (and a few branches derived from it)

### Configuration

N/A

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)


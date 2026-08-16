Rule L060 could give a specific error message
At the moment rule L060 flags something like this:

```
L:  21 | P:   9 | L060 | Use 'COALESCE' instead of 'IFNULL' or 'NVL'.
```

Since we likely know the wrong word, it might be nice to actually flag that instead of both `IFNULL` and `NVL` - like most of the other rules do.

That is it should flag this:

```
L:  21 | P:   9 | L060 | Use 'COALESCE' instead of 'IFNULL'.
```
 Or this:

```
L:  21 | P:   9 | L060 | Use 'COALESCE' instead of 'NVL'.
```

As appropriate.

What do you think @jpy-git ?


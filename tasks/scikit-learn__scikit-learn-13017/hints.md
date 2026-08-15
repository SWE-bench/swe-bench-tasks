I think we should allow negative indices, if only because we are supporting
various other numpy indexing syntaxes and users would expect it. Current
behaviour doesn't look so good!

Can I work on this? My initial thought process is to look at the `ColumnTransformer` class and see how column names are being parsed. The `ColumnTransformer` is located inside `sklearn/compose/_column_transformer.py`. I'd like to give this a look and hack into what's happening. This seems easy for a first timer like me. 
I'm uncertain quite how easy it is. after you've familiarised yourself with the code a little, please add a test to sklearn/compose/tests/test_column_transformer.py asserting the desired behaviour, as proposed by @albertcthomas. Submit a PR. Then go ahead and try to fix it.
It is the validation of the remainder that is going wrong:

```
In [15]: tf_1._remainder                                                                                                                                                                                            
Out[15]: ('remainder', 'passthrough', [0, 1, 2])   <--- wrong

In [16]: tf_2._remainder                                                                                                                                                                                            
Out[16]: ('remainder', 'passthrough', [0, 1])
```

This is because the set operation here to get `remaining_idx` does not work with negative indices:

https://github.com/scikit-learn/scikit-learn/blob/354c8c3bc3e36c69021713da66e7fa2f6cb07756/sklearn/compose/_column_transformer.py#L298-L304

Maybe we should convert the negative indices to positive ones in `_get_column_indices` ?
Yes, that sounds like the right solution.

thanks @jorisvandenbossche for investigating the issue.
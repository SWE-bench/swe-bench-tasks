I would like to investigate this.
Just change the **random_state** parameter to **0** i.e. **random_state=_0_**. This will give you the same result
@Julisam sorry I don't follow.
I think ``max_iter`` should probably be the total number of calls for consistency with ``RandomForest`` (and gradient boosting?). That means if max_iter is reached and you call fit it shouldn't do anything (and maybe give an error?).

Not 100% this is the least unexpected behavior, though.
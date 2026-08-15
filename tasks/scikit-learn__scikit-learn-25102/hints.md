I mitigating regarding this topic.

Indeed, we already preserve the `dtype` if it is supported by the transformer and the type of data is homogeneous:

```python
In [10]: import numpy as np
    ...: from sklearn.datasets import load_iris
    ...: from sklearn.preprocessing import StandardScaler
    ...: 
    ...: X, y = load_iris(return_X_y=True, as_frame=True)
    ...: X = X.astype(np.float32)
    ...: 
    ...: selector = StandardScaler()
    ...: selector.set_output(transform="pandas")
    ...: X_out = selector.fit_transform(X, y)
    ...: print(X_out.dtypes)
sepal length (cm)    float32
sepal width (cm)     float32
petal length (cm)    float32
petal width (cm)     float32
dtype: object
```

Since all operations are done with NumPy arrays under the hood, inhomogeneous types will be converted to a single homogeneous type. Thus, there is little benefit in casting the data type since the memory was already allocated.

Heterogeneous `dtype` preservation could only happen if transformers would use `DataFrame` as a native container without conversion to NumPy arrays. It would also force all transformers to perform processing column-by-column.

So in the short term, I don't think that this feature can be supported or can be implemented.
Thank you very much for the quick response and clarification. 
Indeed, I should have specified that this is about inhomogeneous and not directly by the transformer supported data/dtypes.

Just to clarify what I thought would be possible: 
I thought more of preserving the dtype in a similar way as (I think) sklearn preserves column names/index.
I.e. doing the computation using a NumPy array, then creating the DataFrame and reassigning the dtypes. 
This would of course not help with memory, but preserve the statistically relevant information mentioned above. 
Then, later parts of a Pipeline could still select for a specific dtype (especially categorical). 
Such a preservation might be limited to transformers which export the same or a subset of the inputted features.
I see the advantage of preserving the dtypes, especially in the mixed dtypes case. It is also what I think I'd naively expected to happen. Thinking about how the code works, it makes sense that this isn't what happens though.

One thing I'm wondering is if converting from some input dtype to another for processing and then back to the original dtype loses information or leads to other weirdness. Because if the conversions required can't be lossless, then we are trading one problem for another one. I think lossy conversions would be harder to debug for users, because the rules are more complex than the current ones.
> One thing I'm wondering is if converting from some input dtype to another for processing and then back to the original dtype loses information or leads to other weirdness.

This is on this aspect that I am septical. We will the conversion to higher precision and therefore you lose the gain of "preserving" dtype. Returning a casted version will be less surprising but a "lie" because you allocated the memory and then just lose the precision with the casting.

I can foresee that some estimators could indeed preserve the dtype by not converting to NumPy array: for instance, the feature selection could use NumPy array to compute the features to be selected and we select the columns on the original container before the conversion.

For methods that imply some "inplace" changes, it might be even harder than what I would have think:

```python
In [17]: X, y = load_iris(return_X_y=True, as_frame=True)
    ...: X = X.astype({"petal width (cm)": np.float16,
    ...:               "petal length (cm)": np.float16,
    ...:               })

In [18]: X.mean()
Out[18]: 
sepal length (cm)    5.843333
sepal width (cm)     3.057333
petal length (cm)    3.755859
petal width (cm)     1.199219
dtype: float64
```

For instance, pandas will not preserve dtype on the computation of simple statistics. It means that it is difficult to make heterogeneous dtype preservation, agnostically to the input data container.
> 



> One thing I'm wondering is if converting from some input dtype to another for processing and then back to the original dtype loses information or leads to other weirdness.

I see your point here. However, this case only applies to pandas input / output and different precision. The case is then when user has mixed precisions (float64/32/16) on input, computation is done in them highest precision and then casted back to the original dtype. 

What @samihamdan meant is to somehow preserve the consistency of the dataframe (and dataframe only). It's quite a specific use-case in which you want the transformer to cast back to the original dtype. As an example, I can think of a case in which you use a custom transformer which might not benefit from float64 input (vs float32) and will just result in a huge computational burden.

edit: this transformer is not isolated but as a second (or later) step in a pipeline
> What @samihamdan meant is to somehow preserve the consistency of the dataframe (and dataframe only). It's quite a specific use-case in which you want the transformer to cast back to the original dtype.

I think what you are saying is that you want a transformer that is passed a pandas DF with mixed types to output a pandas DF with the same mixed types as the input DF. Is that right?

If I understood you correctly, then what I was referring to with "weird things happen during conversions" is things like `np.array(np.iinfo(np.int64).max -1).astype(np.float64).astype(np.int64) != np.iinfo(np.int64).max -1`. I'm sure there are more weird things like this, the point being that there are several of these traps and that they aren't well known. This is assuming that the transformer(s) will continue to convert to one dtype internally to perform their computations.

> therefore you lose the gain of "preserving" dtype

I was thinking that the gain isn't related to saving memory or computational effort but rather semantic information about the column. Similar to having feature names. They don't add anything to making the computation more efficient, but they help humans understand their data. For example `pd.Series([1,2,3,1,2,4], dtype="category")` gives you some extra information compared to `pd.Series([1,2,3,1,2,4], dtype=int)` and much more information compared to `pd.Series([1,2,3,1,2,4], dtype=float)` (which is what you currently get if the data frame contains other floats (I think).
> I was thinking that the gain isn't related to saving memory or computational effort but rather semantic information about the column. Similar to having feature names. They don't add anything to making the computation more efficient, but they help humans understand their data. For example `pd.Series([1,2,3,1,2,4], dtype="category")` gives you some extra information compared to `pd.Series([1,2,3,1,2,4], dtype=int)` and much more information compared to `pd.Series([1,2,3,1,2,4], dtype=float)` (which is what you currently get if the data frame contains other floats (I think).

This is exactly what me and @samihamdan meant. Given than having pandas as output is to improve semantics, preserving the dtype might help with the semantics too.
For estimators such as `SelectKBest` we can probably do it with little added complexity.

But to do it in general for other transformers that operates on a column by column basis such as `StandardScaler`, this might be more complicated and I am not sure we want to go that route in the short term.

It's a bit related to whether or not we want to handle `__dataframe__` protocol in scikit-learn in the future:

- https://data-apis.org/dataframe-protocol/latest/purpose_and_scope.html

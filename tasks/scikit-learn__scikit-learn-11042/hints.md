Thanks for the report. Please provide [a minimal reproducible example](http://scikit-learn.org/dev/faq.html#what-s-the-best-way-to-get-help-on-scikit-learn-usage).
@rth, I have just finished editing the issue. 
This seems like a bug which happens when `categorical_features != 'all'`, quickly looking at this, this comes from:
https://github.com/scikit-learn/scikit-learn/blob/96a02f3934952d486589dddd3f00b40d5a5ab5f2/sklearn/preprocessing/data.py#L1871-L1872

`X_sel` has the right dtype (float32, because it goes through `OneHotEncoder._fit_transform`)) but `X_not_sel` dtype is float64 so that when you stack them up you end up with a float64 array.

An easy work-around is to convert the array you are calling `fit_transform` on to float32, e.g.:
```py
import numpy as np

from sklearn.preprocessing import OneHotEncoder
enc = OneHotEncoder(dtype=np.float32, categorical_features=[0, 1])

x = np.array([[0, 1, 0, 0], [1, 2, 0, 0]], dtype=int)
sparse = enc.fit(x).transform(x.astype(np.float32))
```

A PR fixing this would be more than welcome though!
I'm not sure what a fix to this should look like. but a note in the dtype
parameter's documentation is worthwhile.

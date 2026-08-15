So it is because of the dtype, so it is probably some overflow. 
It does not give any warning or error though, and this did not happen before.
[float32.pdf](https://github.com/scikit-learn/scikit-learn/files/3194307/float32.pdf)



```python
from sklearn.metrics.pairwise import euclidean_distances
import sklearn
from scipy.spatial.distance import cdist
import matplotlib.pyplot as plt
import numpy as np

X = np.random.uniform(0,2,(100,10000))

ed = euclidean_distances(X)
title_ed = 'euc dist type: {}'.format(X.dtype)
X = X.astype('float32')
ed_ = euclidean_distances(X)
title_ed_ = 'euc dist type: {}'.format(X.dtype)

plt.plot(np.sort(ed.flatten()), label=title_ed)
plt.plot(np.sort(ed_.flatten()), label=title_ed_)
plt.yscale('symlog', linthreshy=1E3)
plt.legend()
plt.show()
```
Thanks for reporting this @lenz3000. I can reproduce with the above example. It is likely due to https://github.com/scikit-learn/scikit-learn/pull/13554 which improves the numerical precision of `euclidean_distances` in some edge cases, but it looks like it has some side effects. It would be worth invesigating what is happening in this example (were the data is reasonably normalized).

cc @jeremiedbb
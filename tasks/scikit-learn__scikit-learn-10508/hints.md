`le.transform([])` will trigger an numpy array of `dtype=np.float64` and you fit something which was some string.

```python
from sklearn.preprocessing import LabelEncoder                                       
import numpy as np                                                                   
                                                                                     
le = LabelEncoder()                                                                  
X = np.array(["a", "b"])                                                             
le.fit(X)                                                                            
X_trans = le.transform(np.array([], dtype=X.dtype))
X_trans
array([], dtype=int64)
```
I would like to take it up. 
Hey @maykulkarni go ahead with PR. Sorry, please don't mind my referenced commit, I don't intend to send in a PR.

I would be happy to have a look over your PR once you send in (not that my review would matter much) :)
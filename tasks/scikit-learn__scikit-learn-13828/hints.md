Yes, it should be providing a better error message. A pull request doing so
is welcome.

I don't know affinity propagation well enough to comment on whether we
should support a sparse graph as we do with dbscan.. This is applicable
only when a sample's nearest neighbours are all that is required to cluster
the sample.

For DBSCAN algorithm, sparse distance matrix is supported.
I will make a pull request to fix the support of sparse affinity matrix of Affinity Propagation.
It seems numpy does not support calculate the median value of a sparse matrix:
```python
from scipy.sparse import csr
a=csr.csr_matrix((3,3))
np.mean(a)
# 0.0
np.median(a)
# raise Error similar as above
```
How to fix this ?
DBSCAN supports sparse distance matrix because it depends on nearest
neighborhoods, not on all distances.

I'm not convinced this can be done.

Affinity Propagation extensively use dense matrix operation in its implementation.
I think of two ways to handle such situation.
1. sparse matrix be converted to dense in implementation 
2. or disallowed as input when affinity = 'precomputed'
The latter. A sparse distance matrix is a representation of a sparsely
connected graph. I don't think affinity propagation can be performed on it

raise an error when user provides a sparse matrix as input (when affinity = 'precomputed')?

Yes please

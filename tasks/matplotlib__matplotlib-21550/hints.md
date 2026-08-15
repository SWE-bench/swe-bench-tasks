Thanks for testing the RC!  Do you really need the interactive code _and_ networkx to reproduce?  We strongly prefer self-contained issues that don't use downstream libraries.  
I guess the interactive code may be stripped out. will try. 

````
# Networks graph Example : https://github.com/ipython/ipywidgets/blob/master/examples/Exploring%20Graphs.ipynb
%matplotlib inline
import matplotlib.pyplot as plt
import networkx as nx

def plot_random_graph(n, m, k, p):
    g = nx.random_lobster(16, 0.5 , 0.5/16)
    nx.draw(g)
    plt.title('lobster')
    plt.show()

plot_random_graph(16, 5 , 5 , 0)
````

with Matplotlib-3.4.3
![image](https://user-images.githubusercontent.com/4312421/139744954-1236efdb-7394-4f3d-ba39-f01c4c830a41.png)


with matplotlib-3.5.0.dev2445+gb09aad279b-cp39-cp39-win_amd64.whl
![image](https://user-images.githubusercontent.com/4312421/139745259-057a8e2c-9b4b-4efc-bae1-8dfe156d02e1.png)

code simplified shall be:
````
%matplotlib inline
import matplotlib.pyplot as plt
import networkx as nx

g = nx.random_lobster(16, 0.5 , 0.5/16)
nx.draw(g)
plt.title('lobster')
plt.show()
````
FWIW the problem seems to be with `LineCollection`, which is used to represent undirected edges in NetworkX's drawing functions.
Bisecting identified 1f4708b310 as the source of the behavior change.
It would still be helpful to have this in pure matplotlib. What does networkx do using line collection that the rc breaks?   Thanks!
Here's the best I could do to boil down `nx_pylab.draw_networkx_edges` to a minimal example:

```python
import numpy as np                                                              
import matplotlib.pyplot as plt                                                 
import matplotlib as mpl                                                        
                                                                                
loc = np.array([[[ 1.        ,  0.        ],                                    
        [ 0.30901695,  0.95105657]],                                            
                                                                                
       [[ 1.        ,  0.        ],                                             
        [-0.80901706,  0.58778526]],                                            
                                                                                
       [[ 1.        ,  0.        ],                                             
        [-0.809017  , -0.58778532]],                                            
                                                                                
       [[ 1.        ,  0.        ],                                             
        [ 0.3090171 , -0.95105651]],                                            
                                                                                
       [[ 0.30901695,  0.95105657],                                             
        [-0.80901706,  0.58778526]],                                            
                                                                                
       [[ 0.30901695,  0.95105657],                                             
        [-0.809017  , -0.58778532]],                                            
                                                                                
       [[ 0.30901695,  0.95105657],                                             
        [ 0.3090171 , -0.95105651]],                                            
                                                                                
       [[-0.80901706,  0.58778526],                                             
        [-0.809017  , -0.58778532]],                                            
                                                                                
       [[-0.80901706,  0.58778526],                                             
        [ 0.3090171 , -0.95105651]],                                            
                                                                                
       [[-0.809017  , -0.58778532],                                             
        [ 0.3090171 , -0.95105651]]])                                           
fig, ax = plt.subplots()                                                        
lc = mpl.collections.LineCollection(loc, transOffset=ax.transData)              
ax.add_collection(lc)                                                           
minx = np.amin(np.ravel(loc[..., 0]))                                           
maxx = np.amax(np.ravel(loc[..., 0]))                                           
miny = np.amin(np.ravel(loc[..., 1]))                                           
maxy = np.amax(np.ravel(loc[..., 1]))                                           
w = maxx - minx                                                                 
h = maxy - miny                                                                 
padx, pady = 0.05 * w, 0.05 * h                                                 
corners = (minx - padx, miny - pady), (maxx + padx, maxy + pady)                
ax.update_datalim(corners)                                                      
ax.autoscale_view()                                                             
plt.show()
```

With 3.4.3 this gives:

![mpl_3 4 3](https://user-images.githubusercontent.com/1268991/139796792-459be85d-cf05-4077-984c-e4762d2d0562.png)

and with 3.5.0rc1:
![mpl_3 5 0rc1](https://user-images.githubusercontent.com/1268991/139796823-6bc62690-dca4-4ec8-b0a3-2f01ff873ca1.png)




The problem is passing `transOffset`, which previously did nothing if you didn't pass `offsets`, but now does all the time. That was a mistake and not supposed to have been changed, I think.
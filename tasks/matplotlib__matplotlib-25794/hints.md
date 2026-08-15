Well - there should be some consistency at least.  I think @brunobeltran is looking at overhauling this?
>  Well - there should be some consistency at least.

new motto for matplotlib? :)
Consistent, community-developed, flexible with lots of features.  You may choose two.  
Hello I would like to starting contributing, I came across this issue and I would like to know if this would be a possible fix on the scatter function
```python
if linewidths is not None and kwargs.get('linewidth') is not None:
    raise TypeError('linewidths and linewidth cannot be used simultaneously.')
if edgecolors is not None and kwargs.get('edgecolor') is not None:
    raise TypeError('edgecolors and edgecolor cannot be used simultaneously.')
```

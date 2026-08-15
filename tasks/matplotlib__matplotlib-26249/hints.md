Thank you for your clear report and diagnosis @2sn.  I have reproduced this with our `main` development branch.
Change this: 
https://github.com/matplotlib/matplotlib/blob/f017315dd5e56c367e43fc7458fd0ed5fd9482a2/lib/mpl_toolkits/mplot3d/axes3d.py#L2252

to 

```  
if kwargs.get('color', None):
    xs, ys, zs, s, c, kwargs['color'] = cbook.delete_masked_points(xs, ys, zs, s, c, kwargs['color'])
else:
    xs, ys, zs, s, c = cbook.delete_masked_points(xs, ys, zs, s, c)
```

on first sight solve the problem. 
I am willing to take this issue if no one alredy did it.
@artemshekh go for it
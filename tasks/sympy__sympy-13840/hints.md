I suppose these should be added, considering  JavaScript does have `Math.max` and `Math.min`. 

Meanwhile, there is a workaround: Max(x, y) is equivalent to `(x+y+Abs(x-y))/2`, and Abs is supported. 
```
>>> jscode((1+y+Abs(1-y)) / 2)
'(1/2)*y + (1/2)*Math.abs(y - 1) + 1/2'
```
Similarly, Min(x, y) is equivalent to (x+y-Abs(x-y))/2.
  
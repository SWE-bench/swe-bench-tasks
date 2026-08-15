It can't denest:
```python
In [4]: arg(I)
Out[4]: 
π
─
2

In [5]: arg(arg(I))
Out[5]: 0
```
Also it's different for positive and negative inputs:
```python
In [8]: arg(arg(I))
Out[8]: 0

In [9]: arg(arg(-I))
Out[9]: π
```
Can the maximum level before stability be 2?
```python
>>> arg(arg(arg(x)))
arg(arg(arg(x)))
```
```python
In [8]: arg(arg(I))
Out[8]: 0

In [9]: arg(arg(-I))
Out[9]: π

In [10]: arg(arg(arg(I)))
Out[10]: nan

In [11]: arg(arg(arg(-I)))
Out[11]: 0
```
I suppose that once we have 4 args we're guaranteed a nan but that doesn't seem like an especially useful simplification:
```python
In [13]: arg(arg(arg(arg(-I))))
Out[13]: nan
```
ok - a low-priority limit of 4
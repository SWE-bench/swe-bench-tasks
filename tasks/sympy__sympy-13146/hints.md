A strange bug. The floating point numbers appear to be identical:

```
In [30]: expr2.evalf(5).args[1].args[1]._mpf_
Out[30]: (0, 5, -1, 3)

In [31]: expr1.evalf(5).args[1].args[1]._mpf_
Out[31]: (0, 5, -1, 3)

In [32]: expr1.evalf(5).args[0]._mpf_
Out[32]: (0, 1, -1, 1)

In [33]: expr2.evalf(5).args[0]._mpf_
Out[33]: (0, 1, -1, 1)
```

It also works if you use the default precision:

```
In [27]: expr1.evalf() - expr2.evalf()
Out[27]: 0

In [28]: (expr1 - expr2).evalf()
Out[28]: 0
```

More succinctly, the problem is
```
>>> (-2)**(-S(10)/3)
-(-2)**(2/3)/16
```
Pow is supposed to use the principal branch, which means (-2) has complex argument pi, which under exponentiation becomes `-10*pi/3` or equivalently `2*pi/3`. But the result of automatic simplification is different: its argument is -pi/3. 

The base (-1) is handled correctly, though.
```
>>> (-1)**(-S(10)/3)
(-1)**(2/3)
```
Hence the inconsistency, because the simplified form of the product has (-1) in its base.
getitem does not infer the actual unpacked value
When trying to call `Dict.getitem()` on a context where we have a dict unpacking of anything beside a real dict, astroid currently raises an `AttributeError: 'getitem'`, which has 2 problems:

- The object might be a reference against something constant, this pattern is usually seen when we have different sets of dicts that extend each other, and all of their values are inferrable. 
- We can have something that is uninferable, but in that case instead of an `AttributeError` I think it makes sense to raise the usual `AstroidIndexError` which is supposed to be already handled by the downstream.


Here is a short reproducer;

```py
from astroid import parse


source = """
X = {
    'A': 'B'
}

Y = {
    **X
}

KEY = 'A'
"""

tree = parse(source)

first_dict = tree.body[0].value
second_dict = tree.body[1].value
key = tree.body[2].value

print(f'{first_dict.getitem(key).value = }')
print(f'{second_dict.getitem(key).value = }')


```

The current output;

```
 $ python t1.py                                                                                                 3ms
first_dict.getitem(key).value = 'B'
Traceback (most recent call last):
  File "/home/isidentical/projects/astroid/t1.py", line 23, in <module>
    print(f'{second_dict.getitem(key).value = }')
  File "/home/isidentical/projects/astroid/astroid/nodes/node_classes.py", line 2254, in getitem
    return value.getitem(index, context)
AttributeError: 'Name' object has no attribute 'getitem'
```

Expeceted output;
```
 $ python t1.py                                                                                                 4ms
first_dict.getitem(key).value = 'B'
second_dict.getitem(key).value = 'B'

```


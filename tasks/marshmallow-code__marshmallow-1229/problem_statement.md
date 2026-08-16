`only` argument inconsistent between Nested(S, many=True) and List(Nested(S))
```python
from pprint import pprint

from marshmallow import Schema
from marshmallow.fields import Integer, List, Nested, String


class Child(Schema):
    name = String()
    age = Integer()


class Family(Schema):
    children = List(Nested(Child))


class Family2(Schema):
    children = Nested(Child, many=True)

family = {'children':[
    {'name': 'Tommy', 'age': 12},
    {'name': 'Lily', 'age': 15},
]}

pprint(Family( only=['children.name']).dump(family).data)
pprint(Family2( only=['children.name']).dump(family).data)
```
returns
```
{'children': [{'age': 12, 'name': 'Tommy'}, {'age': 15, 'name': 'Lily'}]}
{'children': [{'name': 'Tommy'}, {'name': 'Lily'}]}
```

tested with marshmallow 2.15.4

The same applies to `exclude` argument.

2.x: Nested(many=True) eats first element from generator value when dumping
As reproduced in Python 3.6.8:

```py
from marshmallow import Schema, fields

class O(Schema):
    i = fields.Int()

class P(Schema):
    os = fields.Nested(O, many=True)

def gen():
    yield {'i': 1}
    yield {'i': 0}

p = P()
p.dump({'os': gen()})
# MarshalResult(data={'os': [{'i': 0}]}, errors={})
```

Problematic code is here:

https://github.com/marshmallow-code/marshmallow/blob/2.x-line/src/marshmallow/fields.py#L447

And here:

https://github.com/marshmallow-code/marshmallow/blob/2.x-line/src/marshmallow/schema.py#L832

The easiest solution would be to cast `nested_obj` to list before calling `schema._update_fields`, just like a normal Schema with `many=True` does.

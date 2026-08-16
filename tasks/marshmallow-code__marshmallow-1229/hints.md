For now I'm using following workaround:
```python
class ListFix(List):
    @property
    def only(self):
        return getattr(self.container, 'only')

    @only.setter
    def only(self, new_options):
        original_options = getattr(self.container, 'only', ())
        if original_options:
            new_options &= type(new_options)(original_options)
        setattr(self.container, 'only', new_options)


class Child(Schema):
    name = String()
    age = Integer()


class Family(Schema):
    children = ListFix(Nested(Child))
```

the option propagation code was taken from `BaseSchema.__apply_nested_option`

maybe apply option code (the part I have copied to ListFix property) should be moved to field?

**Edited:** Just found a nasty side effect of my "fix"

```python
family = {'children': [
    {'name': 'Tommy', 'age': 12},
    {'name': 'Lily', 'age': 15},
]}

for family_schema in (
        Family(),
        Family(only=['children.name']),
        Family2(),
        Family2(only=['children.name']),
):
    pprint(family_schema.dump(family).data)
```
prints
```
{'children': [{'name': 'Tommy'}, {'name': 'Lily'}]}
{'children': [{'name': 'Tommy'}, {'name': 'Lily'}]}
{'children': [{'age': 12, 'name': 'Tommy'}, {'age': 15, 'name': 'Lily'}]}
{'children': [{'name': 'Tommy'}, {'name': 'Lily'}]}
```
Thanks @rooterkyberian . Let's continue discussion of this in #779.
Unfortunately, there are no way to do that. The `autoclass` directive always shows its signature automatically.

+1: I agree that it is valuable if we can show explanations both of the class and `__init__()` method independently.
Can this issue be renamed to smth. like "Omitting constructor signature from class header" ? I had a hard time finding it.
My use case is documenting a serializer, a class derived from [rest_framework.serializers.ModelSerializer](https://www.django-rest-framework.org/api-guide/serializers/).

```
class OrderSerializer(serializers.ModelSerializer):
  ...
```

This class is only constructed by the framework, and never constructed by the user, but in my docs I get

```
class OrderSerializer(instance=None, data=<class 'rest_framework.fields.empty'>, **kwargs)
  ...
```

There is no way to remove the constructor signature, which is long, ugly, and totally irrelevant for people reading the docs.
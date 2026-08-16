Solution 1. is preferable to 2., I think. That said, there are some use cases where it's awkward to call additional kwargs "metadata". `location` in webargs is one that comes to mind.

```python
# current API
"some_query_param": fields.Bool(location="query")
```

though we could probably wrap all the fields in webargs to take the additional `location` argument. 🤔 
I wanted to note that even webargs' `location` doesn't necessarily make the case against `metadata=...`. I was surprised/confused at first when I went looking for `location` in marshmallow and found no mention of it. At the cost of a little bit of verbosity, it would make it easier to understand how marshmallow is functioning.

Relatedly, the plan in https://github.com/marshmallow-code/webargs/issues/419 includes making `location=...` for webargs a thing of the past.
cc @jtrakk . This was your suggestion in https://github.com/marshmallow-code/marshmallow/issues/779#issuecomment-522282845 . I'm leaning towards this more and more.
+1 on this, IMHO biggest problem of `self.metadata=kwargs` is not that it's unexpected, but that it's not generating errors on wrong keyword arguments, which is pretty annoying due frequent api changes :-) so - you can find mistakes only later, all your typos in metadata field...
One one hand, I think it is better to specify `metadata=`. More explicit.

OTOH, this will make my models a bit more verbose:

```py
class MyModel(ma.Schema:
    some_int = ma.fields.Int(
        required=True,
        validate=ma.validate.OneOf([1, 2, 3]),
        metadata={"description": "This string explains what this is all about"}
    )
```

For such a use case, the shortcut of using extra kwargs as metadata is nice.

If we went with solution 2, users would be able to extend the whitelist with their own stuff. Apispec could extend it with the keyword arguments it expects (valid OpenAPI attributes) and we could even catch typos inside metadata, while solution 1 blindly accepts anything in metadata.

However, this would prevent accepting arbitrary attributes in metadata, which sucks. E.g. in apispec, we also accept any `"x-..."` attribute. So we'd need to genericize the whitelist to a callable mechanism. And we end up with a gas factory feature while we wanted to make thing simple.

Overall, perhaps the downside of 1 (model verbosity) is not that bad.
Agreed. Consider this accepted.

My plan is to deprecate `metadata=kwargs` in a later 3.x release. Let's let the dust settle on v3 before bombarding users with DeprecationWarnings 😅 
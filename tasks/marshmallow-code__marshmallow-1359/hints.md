Thanks for reporting. I don't think I'll have time to look into this until the weekend. Would you like to send a PR? 
I'm afraid I don't have any time either, and I don't really have enough context on the `_bind_to_schema` process to make sure I'm not breaking stuff.
OK, no problem. @lafrech Will you have a chance to look into this?
I've found the patch below to fix the minimal example above, but I'm not really sure what it's missing out on or how to test it properly:
```patch
diff --git a/src/marshmallow/fields.py b/src/marshmallow/fields.py
index 0b18e7d..700732e 100644
--- a/src/marshmallow/fields.py
+++ b/src/marshmallow/fields.py
@@ -1114,7 +1114,7 @@ class DateTime(Field):
         super()._bind_to_schema(field_name, schema)
         self.format = (
             self.format
-            or getattr(schema.opts, self.SCHEMA_OPTS_VAR_NAME)
+            or getattr(getattr(schema, "opts", None), self.SCHEMA_OPTS_VAR_NAME, None)
             or self.DEFAULT_FORMAT
         )
```
    git difftool 3.0.0rc8 3.0.0rc9 src/marshmallow/fields.py

When reworking container stuff, I changed

```py
        self.inner.parent = self
        self.inner.name = field_name
```
into

```py
        self.inner._bind_to_schema(field_name, self)
```

AFAIR, I did this merely to avoid duplication. On second thought, I think it was the right thing to do, not only for duplication but to actually bind inner fields to the `Schema`.

Reverting this avoids the error but the inner field's `_bind_to_schema` method is not called so I'm not sure it is desirable.

I think we really mean to call that method, not only in this case but also generally.

Changing

```py
            or getattr(schema.opts, self.SCHEMA_OPTS_VAR_NAME)
```

into

```py
            or getattr(self.root.opts, self.SCHEMA_OPTS_VAR_NAME)
```

might be a better fix. Can anyone confirm (@sloria, @deckar01)?

The fix in https://github.com/marshmallow-code/marshmallow/issues/1357#issuecomment-523465528 removes the error but also the feature: `DateTime` fields buried into container fields won't respect the format set in the `Schema`.

I didn't double-check that but AFAIU, the change I mentioned above (in container stuff rework) was the right thing to do. The feature was already broken (format set in `Schema` not respected if `DateTime` field in container field) and that's just one of the issues that may arise due to the inner field not being bound to the `Schema`. But I may be wrong.
On quick glance, your analysis and fix look correct @lafrech 
Let's do that, then.

Not much time either. The first who gets the time can do it.

For the non-reg tests :

1/ a test that checks the format set in the schema is respected if the `DateTime` field is in a container field

2/ a set of tests asserting the `_bind_to_schema` method of inner fields `List`, `Dict`, `Tuple` is called from container fields (we can use `DateTime` with the same test case for that)

Perhaps 1/ is useless if 2/ is done.
The documentation of the option says "Leave empty to show all."
```diff
diff --git a/pylint/config/argument.py b/pylint/config/argument.py
index 8eb6417dc..bbaa7d0d8 100644
--- a/pylint/config/argument.py
+++ b/pylint/config/argument.py
@@ -44,6 +44,8 @@ _ArgumentTypes = Union[
 
 def _confidence_transformer(value: str) -> Sequence[str]:
     """Transforms a comma separated string of confidence values."""
+    if not value:
+        return interfaces.CONFIDENCE_LEVEL_NAMES
     values = pylint_utils._check_csv(value)
     for confidence in values:
         if confidence not in interfaces.CONFIDENCE_LEVEL_NAMES:
```

This will fix it.

I do wonder though: is this worth breaking? Probably not, but it is counter-intuitive and against all other config options behaviour to let an empty option mean something different. `confidence` should contain all confidence levels you want to show, so if it is empty you want none. Seems like a bad design choice when we added this, perhaps we can still fix it?...
Thanks for the speedy reply! I don't think we should bother to change how the option works. It's clearly documented, so that's something!
Hm okay. Would you be willing to prepare a PR with the patch? I had intended not to spend too much time on `pylint` this evening 😄 
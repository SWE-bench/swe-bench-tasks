I'm going to accept this provisionally. There's ​a `FIXME` in `models/base.py` specifically about this: # Skip ordering in the format field1__field2 (FIXME: checking # this format would be nice, but it's a little fiddly). fields = (f for f in fields if LOOKUP_SEP not in f) Added in ​d818e0c9b2b88276cc499974f9eee893170bf0a8. Either we should address this, or remove the comment and close as wontfix if "fiddly" turns out to be more effort than it's worth. A test case and a patch showing what "fiddly" actually entails would be great.
I think we can just address this in the document and don't fix it.
​PR
patch updated and new method added.
Any updates? if there is something to change please inform me. I am ready.
Left comments on PR: patch would need to handle JSON paths, which should be valid in ordering since #24747. (Similar issue arises in #29622.)
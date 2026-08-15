Thanks for reporting. This looks like a problem in general with the C and C++ domains, but not immediately trivial to solve.
@jakobandersen, maybe the builtin types can be excluded from the keyword list for the time being?  For example (without knowing much about the internals of sphinx, I admit), the following patch helps (not a real diff to make it clearer):

```diff
diff --git a/sphinx/domains/c.py b/sphinx/domains/c.py
index 06bd65e019b9..9fb8a4141e62 100644
--- a/sphinx/domains/c.py
+++ b/sphinx/domains/c.py
@@ -53,7 +53,6 @@ _keywords = [
     'auto',
     'break',
     'case',
-    'char',
     'const',
     'continue',
     'default',
@@ -62,17 +61,13 @@ _keywords = [
     'else',
     'enum',
     'extern',
-    'float',
     'for',
     'goto',
     'if',
     'inline',
-    'int',
-    'long',
     'register',
     'restrict',
     'return',
-    'short',
     'signed',
     'sizeof',
     'static',
@@ -81,7 +76,6 @@ _keywords = [
     'typedef',
     'union',
     'unsigned',
-    'void',
     'volatile',
     'while',
     '_Alignas',
@@ -89,10 +83,6 @@ _keywords = [
     '_Alignof',
     'alignof',
     '_Atomic',
-    '_Bool',
-    'bool',
-    '_Complex',
-    'complex',
     '_Generic',
     '_Imaginary',
     'imaginary',
```

Or, just for the references, warnings from the C parser could be suppressed so the behavior is like for unknown names; the reference is just ignored.
Indeed, a temporary hax would be desirable, though I'm not sure removing keywords will not have unintended consequences.
I have another datapoint:  Writing something like `int*` also breaks, but seemingly in a different codepath (the above patch doesn't help here).
Indeed, ``int*`` also breaks. The issue is that the field lists can be specified to use a domain role for their argument, so when you write ``:type p: int*`` then it is as if you in some text wrote ``:c:type:`int*` `` because the fields are specified to use the ``c:type`` role. It really should use the ``c:expr`` role. However, underneath it all goes through [``make_xref``](https://github.com/sphinx-doc/sphinx/blob/3.x/sphinx/util/docfields.py#L68), which doesn't actually run the specified role, but blindly creates a ``pending_xref``.
@tk0miya, how much of the API of the ``Field`` class is considered public? I.e., how much may I break in a non-backwards compatible manner? Specifically, it looks like the ``env`` argument is optional, but if we need to lookup the role and run it, we need definitely need it. From a quick check it looks like the call stack to that method always originates in ``DocFieldTransformer``, which always gives an actual environment to the field processing.
Just for reference, until this issue has a proper upstream solution the following ugly hack can be used in `conf.py`:

```python
def setup(app):
    fix_issue_8945()


def fix_issue_8945():
    c_domain = __import__("sphinx.domains.c").domains.c

    for kw in [
        "char",
        "float",
        "int",
        "long",
        "short",
        "void",
        "_Bool",
        "bool",
        "_Complex",
        "complex",
    ]:
        c_domain._keywords.remove(kw)

    def parse_xref_object(self):
        name = self._parse_nested_name()
        self.skip_ws()
        self.skip_string("()")
        # Removing this line as a hacky workaround:
        # self.assert_end()
        return name

    c_domain.DefinitionParser.parse_xref_object = parse_xref_object
```
>how much of the API of the Field class is considered public?

It has not been documented. So it's not public. But it would be better to keep compatibility as possible.

>Specifically, it looks like the env argument is optional, but if we need to lookup the role and run it, we need definitely need it. 

Indeed, its default value is None. So it looks like optional. But, it's always passed actually as you saw. I guess it was added as optional to add it to the end of arguments. Therefore, it is not a breaking change, I think.
Makes sense. Assuming ``env`` is there, the next issue I have run into is that when we have gotten the role function from the domain we need to give it a Docutils ``Inliner`` object (https://github.com/sphinx-doc/sphinx/blob/490c1125be7042c876b53f5728bb98dc7356166b/sphinx/domains/__init__.py#L265).
If I understand correctly, then this object only exists while parsing the document, but we are transforming the field list after parsing.
The inliner ends up in ``SphinxRole`` (https://github.com/sphinx-doc/sphinx/blob/490c1125be7042c876b53f5728bb98dc7356166b/sphinx/util/docutils.py#L355), and a usage search indicates that it is really used extensively, so mocking it in general seems infeasible.

@tk0miya, is there a way to hook into the Docutils parser for field lists? In that case we can split the ``DocFieldTransformer`` into two parts: (1) the handling of type fields (during parsing), and  (2) the rearranging+grouping in the fields as the current post-transform.
How about `ObjectDescription.transform_content()` and `object-description-transform` event? They are hook points to modify field list before `DocFieldTransformer` runs. And `ObjectDescription.after_content()` is also helpful to modify the converted field lists after `DocFieldTransformer`.
Thank you for reporting. I guess Sphinx's post processing has a bug when 3rd party extension resolves a missing-reference.

Could you check this patch works fine?
```
diff --git a/sphinx/transforms/post_transforms/__init__.py b/sphinx/transforms/post_transforms/__init__.py
index e2899d994..54cab4ed6 100644
--- a/sphinx/transforms/post_transforms/__init__.py
+++ b/sphinx/transforms/post_transforms/__init__.py
@@ -96,10 +96,18 @@ class ReferencesResolver(SphinxPostTransform):
                     newnode = self.app.emit_firstresult('missing-reference', self.env,
                                                         node, contnode,
                                                         allowed_exceptions=(NoUri,))
-                    # still not found? warn if node wishes to be warned about or
-                    # we are in nit-picky mode
                     if newnode is None:
+                        # still not found? warn if node wishes to be warned about or
+                        # we are in nit-picky mode
                         self.warn_missing_reference(refdoc, typ, target, node, domain)
+                    elif isinstance(newnode[0], addnodes.pending_xref_condition):
+                        matched = find_pending_xref_condition(node, "*")
+                        if matched:
+                            newnode = matched[0]
+                        else:
+                            logger.warning(__('Could not determine the fallback text for the '
+                                              'cross-reference. Might be a bug.'),
+                                           location=node)
             except NoUri:
                 newnode = None
```

(I'll try this tomorrow. But I need to build the environment to build the example project. I don't know PyQt at all...)
> Thank you for reporting. I guess Sphinx's post processing has a bug when 3rd party extension resolves a missing-reference.
> 
> Could you check this patch works fine?

Not quite. It removes the exception, but the `PyQt5.QtGui.QIcon` return type is still rendered including with the full module name, and it doesn't link to the `Qt` docs.

I was thinking of something more along the lines of

```diff
--- a/sphinx/transforms/post_transforms/__init__.py
+++ b/sphinx/transforms/post_transforms/__init__.py
@@ -69,11 +69,15 @@
 
     default_priority = 10
 
     def run(self, **kwargs: Any) -> None:
         for node in self.document.traverse(addnodes.pending_xref):
-            contnode = cast(nodes.TextElement, node[0].deepcopy())
+            content = find_pending_xref_condition(node, 'resolved')
+            if content:
+                contnode = content.children[0]  # type: ignore
+            else:
+                contnode = cast(nodes.TextElement, node[0].deepcopy())
             newnode = None
 
             typ = node['reftype']
             target = node['reftarget']
             refdoc = node.get('refdoc', self.env.docname)
```
(although you might need to somehow handle the case, where `content` has multiple `children`, I am not 100% sure)

The above patch fixes the error and produces the desired results for the minimal test case, that I have provided, but I am not sure, if it plays well with other components of the reference resolution process.

---

With a little refactoring you should also be able to remove the duplicated code fragments in the following functions:

- `sphinx/domains/python.py:PythonDomain.resolve_xref`
- `sphinx/domains/python.py:PythonDomain.resolve_any_xref`
- `sphinx/domains/python.py:builtin_resolver`
- `sphinx/ext/intersphinx.py:missing_reference`

All these functions are called from `ReferenceResolver.run` either directly:
- `PythonDomain.resolve_xref` by `domain.resolve_xref`
- `PythonDomain.resolve_any_xref` from `self.resolve_anyref` by `domain.resolve_any_xref`

or via connecting to the `missing-reference` event:
- `domains/python.py:builtin_resolver` by `app.connect('missing-reference', builtin_resolver, priority=900)`
- `ext/intersphinx.py:missing_reference` by `app.connect('missing-reference', missing_reference)`)

---

> (I'll try this tomorrow. But I need to build the environment to build the example project. I don't know PyQt at all...)

You shouldn't need any `PyQt` knowledge for this. The reason why `Qt` is involved here is that `Qt` doesn't have a full Python documentation, because it's a C++ wrapper. So the `sphinx-qt-documentation` plugin just makes it possible to automatically link from a python type to documentation of the equivalent C++ type. For example, the `PyQt5.QtGui.QIcon` return type in `foo.py` should link to [the C++ docs for the `QIcon` class](https://doc.qt.io/qt-5/qicon.html).
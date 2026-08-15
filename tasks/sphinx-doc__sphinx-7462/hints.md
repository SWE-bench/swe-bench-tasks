Changing
https://github.com/sphinx-doc/sphinx/blob/b3e26a6c851133b82b50f4b68b53692076574d13/sphinx/domains/python.py#L117-L122
to
```python
            if node.elts:
                result = []
                for elem in node.elts:
                    result.extend(unparse(elem))
                    result.append(addnodes.desc_sig_punctuation('', ', '))
                result.pop()
            else:
                result = [addnodes.desc_sig_punctuation('', '('),
                          addnodes.desc_sig_punctuation('', ')')]
            return result
```
seems to solve the problem for me generating `Tuple[()]` in docs.

So it looks like empty tuples should be handled separately.
Heh, I didn't know this syntax was possible, but not surprising since it's valid in Python itself.

I have wondered if we could potentially run the Python parser on the text inside the brackets. Jinja syntax is mostly the same as Python.
Perhaps we can leverage [this](https://github.com/pallets/jinja/blob/main/src/jinja2/parser.py#L223L232) from the Jinja parser, either calling it directly or mimicking its behavior.

Note that (IIUC) it returns an `Assign` object if it's a standalone tag or an `AssignBlock` if it's part of a set/endset pair.

```
    def parse_set(self) -> t.Union[nodes.Assign, nodes.AssignBlock]:
        """Parse an assign statement."""
        lineno = next(self.stream).lineno
        target = self.parse_assign_target(with_namespace=True)
        if self.stream.skip_if("assign"):
            expr = self.parse_tuple()
            return nodes.Assign(target, expr, lineno=lineno)
        filter_node = self.parse_filter(None)
        body = self.parse_statements(("name:endset",), drop_needle=True)
        return nodes.AssignBlock(target, filter_node, body, lineno=lineno)
```
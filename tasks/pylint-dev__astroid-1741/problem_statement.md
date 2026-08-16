Consider creating a ``UninferableType`` or ``_Uninferable`` class
I opened https://github.com/microsoft/pyright/issues/3641 as I wondered why `pyright` didn't recognise how we type `Uninferable`. Normally they are a little bit more up to date than `mypy` so I wondered if this was intentional.

Turns out it is. According to them, the way we currently handle the typing of `Uninferable` is incorrect and should ideally be refactored.
As we're stille early days into the typing of `astroid` I think there is still chance to do this.

Their suggestion is to create a private class (`_Uninferable`) which `Uninferable` can then instantiate. One of the issues with this is that we tend to require `Uninferable` as a type in `pylint` as well and so we would need to import that private class as well.
We could also create a public class, perhaps suffixed with `Type`, which we document as only being useful for typing.

Let me know if you guys thinks this is something we should do and what approach is best.

/CC @cdce8p As you're likely interested in this.

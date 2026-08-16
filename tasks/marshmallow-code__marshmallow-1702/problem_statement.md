RFC: Change the way we store metadata?
Users are often bit by the fact that fields store arbitrary keyword arguments as metadata. See https://github.com/marshmallow-code/marshmallow/issues/683.

> ...The reasons we use **kwargs instead of e.g. `metadata=` are mostly historical. The original decision was that storing kwargs 1) was more concise and 2) saved us from having to come up with an appropriate name... "metadata" didn't seem right because there are use cases where the things your storing aren't really metadata. At this point, it's not worth breaking the API.

> Not the best reasons, but I think it's not terrible. We've discussed adding a [whitelist of metadata keys](https://github.com/marshmallow-code/marshmallow/issues/683#issuecomment-385113845) in the past, but we decided it wasn't worth the added API surface.

_Originally posted by @sloria in https://github.com/marshmallow-code/marshmallow/issues/779#issuecomment-522283135_

Possible solutions:

1. Use `metadata=`.
2. Specify a whitelist of allowed metadata arguments.

Feedback welcome!

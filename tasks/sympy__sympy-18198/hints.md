Is your code thread-safe?
> Is your code thread-safe?

I didn't check it.
`global_parameters` is singleton and relegates every operations to `global_foo` it contains, so hopefully it will cause no problem as long as `global_foo` does the job right.

Can you suggest the way to check its thread safety?
We should really use thread local storage rather than global variables. Mutable global variables that are not thread-local are not thread-safe.
> We should really use thread local storage rather than global variables. Mutable global variables that are not thread-local are not thread-safe.

Thanks. I didn't know about thread safety before. I'm curious: does the current approach in `core.evaluate` satisfies thread safety? How does it achieve this?
Also, then how can I ensure the thread safety of `global_parameters`? Will blocking suggestion 2 (make the global parameter mutable by implementing setter) do? 
I don't think that the current approach is thread-safe because it just uses a list. That list will be shared between threads so if one thread sets global evaluate to True then it will affect the other threads. To be thread-safe this global needs to use thread-local storage.
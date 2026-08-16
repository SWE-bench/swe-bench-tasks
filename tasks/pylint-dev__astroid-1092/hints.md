Possible duplicate of #1008 
This problem is due to the fact `_infer_context_manager` takes caller function, using its current context, instead of the original callers context. This may be fixed for example by adding data to `Generator` instance, by `infer_call_result` that signifies its possible value types.

I'm not familiar with the codebase, it seems to me that that this is not the correct approach, but, the correct approach is to pass this data inside the `context` structure. But it's not clear to me how to do that.
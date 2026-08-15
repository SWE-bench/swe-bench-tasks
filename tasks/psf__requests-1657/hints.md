Great spot, thanks! We should improve our merging logic here.

I might take a crack at this in an hour or so

Hm. This has always been the behaviour of how per-request hooks work with session hooks but it isn't exactly intuitive. My concern is whether people are relying on this behaviour since the logic in `merge_setting` hasn't really changed in over a year (at least).

I have to wonder if this did the same thing on older versions of requests or if I'm just remembering incorrectly. Either way, the simplest solution would be to not try to special case this inside of `merge_setting` but to use a different function, e.g., `merge_hooks` (or more generally `merge_lists`) to create a merged list of both.

The simplest way to avoid duplication is: `set(session_setting).merge(request_setting)`.

Still I'm not 100% certain this is the expected behaviour and I don't have the time to test it right now. I'll take a peak later tonight.

Let me clarify: session hooks are completely ignored (in version 2.0.0) regardless of whether any per-request hooks were set. They used to work in Requests 1.2.3.

Ah that's a big help.

In fact, I have not tried this yet, but I think it will make writing code compatible with Python 2 and Python 3 much more difficult. In working around the Python 2 issue by encoding the unicode filename, it is likely that a Python 3 issue will be introduced. This is going to require version specific encoding handling to ensure a unicode filename under Python 3 and a non-unicode filename under Python 2.

@sjagoe I have a question: if you provide us a unicode filename, what encoding should we render that with when transmitting that over the wire?

@Lukasa Admittedly, that is an issue. There is no way for you to know. I guess in the past is just encoded to `ascii`?

In which case, this issue is still two things: 
- v2.5.1 broke compatibility with v2.5.0.
- I have just verified that under Python 3, if the filename _is_ encoded beforehand, then the original issue I reported under Python 2 rears its head. That is, requests does not send the filename and my server sees the filename simply as `'file'`, instead of the original.

EDIT: To clarify, under Python 3, a Unicode filename is _required_ (any encoded filename, e.g. `ascii`, `utf-8`, etc, is not sent to the server) and under Python 2, and encoded filename is _required_.

Agreed.

What we need, I think, is for `guess_filename` to check on `basestring` and then call `to_native_str`.

I would even be okay with it if a unicode filename was rejected outright with an exception, requiring the user to explicitly encode, but I don't know what the policy of requests is wrt user-annoying strictness ;-)

Of course, in the interest of compatibility, using `to_native_str` for any 2.5.x fixes would be the best way forward in any case.

So the reality is that we need to unbreak this until 3.0 at which point we can redefine the requests interface for this. I have an idea for a solution and am working on a pull request.

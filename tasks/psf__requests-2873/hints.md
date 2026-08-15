Thanks for this report. This comes because we calculate the length of the StringIO, but don't account for where it is seeked to. 

As I see it we have two options: we can either always `seek(0)` before sending a body, or we can use `tell()` to adjust the content length. 

On balance, I think the first is probably better: we already seek(0) in some cases (e.g. auth handlers), so this would be consistent. The downside is that it makes it harder for someone to upload a partial file from disk, though I suspect that's a minor use-case. 

@sigmavirus24 thoughts?

This isn't our fault. If you do this:

```
import StringIO

s = StringIO.StringIO()
s.write('foobarbogus')
print(s.read())
```

You will get nothing. By writing you've moved the fake pointer. We send what we can. That said, we're sending a content-length of whatever is in the buffer because we look at `s.len` so we're telling the server we're sending something with 11 bytes but sending nothing and that's they the server hangs.

This is how `StringIO` instances work and misusing them is not a bug in requests because partial file uploads are _very_ desirable. Especially if you're trying to split a file up into multiple requests (e.g., uploading very large objects to S3 or an OpenStack Swift service).

There's only so far I will go in helping a user not shoot themselves in the foot. The line I draw is in doing the wrong thing for users who actually know what they're doing.

> we already seek(0) in some cases (e.g. auth handlers), so this would be consistent.

I've always argued that that behaviour is wrong too. I still don't like it.

I see now that this applies to file objects as well which makes sense. I would favor using the current location of the stream by inspecting `tell()`. That to me is part of the benefit and contract of using a file-like object.

It will be more burdensome for developers to get around your forced `seek(0)` than for developers to add a `seek(0)` themselves when needed. If the latter case were more common, I could see an ease-of-use argument. Given that there hasn't been a reported issue before, this scenario is probably rare and reserved for more advanced usage.

@sigmavirus24: Are you opposed to setting the `Content-Length` to `s.len - s.tell()`?

To be clear, my expectation was that the post request would have an empty body precisely for the reason that you state. The surprise was that the request hung, ie. the `Content-Length` is set to the full size, rather than what's remaining.

No I'm not opposed to that, but that is not necessarily applicable to every case where you have `s.len`. `super_len`'s logic would need to change drastically. You basically want [`super_len`](https://github.com/kennethreitz/requests/blob/master/requests/utils.py#L50) to look like this:

``` py
def super_len(o):
    total_len = 0
    current_position = 0
    if hasattr(o, '__len__'):
        total_len = len(o)

    elif hasattr(o, 'len'):
        total_len = o.len

    elif hasattr(o, 'fileno'):
        try:
            fileno = o.fileno()
        except io.UnsupportedOperation:
            pass
        else:
            total_len = os.fstat(fileno).st_size

            # Having used fstat to determine the file length, we need to
            # confirm that this file was opened up in binary mode.
            if 'b' not in o.mode:
                warnings.warn((
                    "Requests has determined the content-length for this "
                    "request using the binary size of the file: however, the "
                    "file has been opened in text mode (i.e. without the 'b' "
                    "flag in the mode). This may lead to an incorrect "
                    "content-length. In Requests 3.0, support will be removed "
                    "for files in text mode."),
                    FileModeWarning
                )

    if hasattr(o, 'tell'):
        current_position = o.tell()

    return max(0, total_len - current_position)

    if hasattr(o, 'getvalue'):
        # e.g. BytesIO, cStringIO.StringIO
        return len(o.getvalue())
```

That said, I've not tested that.

As @braincore stated, it's more the fact that the request will hang due to the mismatch between the `Content-Length` and the actual content that is being sent. The misuse of the `StringIO` API was the reason this was discovered, and not problem to be solved.

> It will be more burdensome for developers to get around your forced seek(0) than for developers to add a seek(0) themselves when needed.

I couldn't agree more, especially due to the rather simple fact that the forced seek would make explicit partial file uploads more difficult than they need to be as mentioned by @sigmavirus24.

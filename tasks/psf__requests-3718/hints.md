@Makman2 it's not immediately obvious where the issue lies here. The specific traceback you're hitting is because the response value is None. I don't see any changes in the critical path for Requests since 2.11.1 that would affect this.

I think it's possibly a gap in requests_mock that's not returning a valid response with a Requests-2.12 request.

Would you be able to provide a repro of this without using the requests_mock module?

Yup, I think @nateprewitt has it: if you can't get a repro that doesn't involve requests_mock I think this issue is almost certainly with their code.

alright thx I'm filing the issue at `requests_mock` :+1:

Submitted here: https://bugs.launchpad.net/requests-mock/+bug/1642396

@Makman2 I went **way** down the rabbit hole and believe I've found an answer. This is in fact the product of a combination of changes in 2.12 and the way you're mocking objects in your tests.

You're currently mocking responses with a Response object that only the status_code initialized.
This is a really simple repro of your issue.

``` python
import requests
r = requests.Response()
r.status_code = 200
r.content
```

`send()` in `requests.Session` always calls `.content` on streams to ensure they're consumed. When this is called on the empty response, it raises an AttributeError previously caught. This exception was removed in 327512f, oddly enough as a fix for requests_mock, because it was deemed too broad. The implication of this is we now require all adapters to support `raw` in their responses which conflicts somewhat with our documentation. I'll leave it to @Lukasa to determine the next steps.

As for getting your tests working with Requests-2.12, I'd suggest simply setting `Response.raw = io.BytesIO()`, or some file-like object, [here](https://github.com/coala/coala-bears/blob/master/tests/general/InvalidLinkBearTest.py#L48).

Just as another breadcrumb here, this was a concern raised in the PR (#3607) but the answer wasn't immediately clear.

Hrm. I think we should resolve any documentation conflicts, but otherwise I'm fine with requiring that `raw` be present.

I should note that actually the only requirement is that `.raw` be present while we don't have `._content`. 

Thanks very much, seems the `.raw = io.BytesIO` thing is working :) It's good to have higher versions of `requests` supported :+1: 

From a requests-mock perspective [bug 1642697](https://bugs.launchpad.net/requests-mock/+bug/1642697) was filed that was hit because of the exact same removal of AttributeError  handling in 327512f. This only affects the requests-mock tests and not the mocking itself but is likely the same result.

From a requests-mock usage perspective (which should probably go elsewhere, but i'm not sure where) there's a few things you can fix in your tests to not have this problem. 

1). It's unlikely you really want a custom matcher, A matcher is the code that checks if you want to return a response. When you do a requests_mock.get() or .register_uri() it creates a matcher for you and you can regexp or a whole variety of things there. You can then attach a function that fills in a response for you, and requests_mock will handle making it a response that requests understands [1].

It's fine/expected to make register each url you are using with it's own response rather than try to cram everything into the same custom matcher.

2). requests_mock.create_response() is a function that is used to create a HTTPResponse that requests understands and it's public for just this reason. If you use this instead of constructing your own requests.Response it will patch all this stuff for you. 

3). update to requests_mock 1.x. There's no API break, it had just been stable long enough to not be considered a 0.x release any more. There's also probably not anything you really need from the 1.x branch but it will be less likely to break with new requests releases.

[1] http://requests-mock.readthedocs.io/en/latest/response.html#dynamic-response

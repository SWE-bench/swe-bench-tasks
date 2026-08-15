>  Confirmation that connection pooling is not currently in use would be a good starting point; in other words: we should confirm that linkchecking of multiple URLs on a single host results in multiple TCP connections. Ideally this should be written as a test case.

I think that the [`mocket` socket-mocking library](https://github.com/mindflayer/python-mocket/) could be a very nice match for this testing use case.

I'm experimenting with it locally at the moment; initially it seems to be good at mocking the client-side sockets, but when mocking the communication between the linkcheck (client) and [test HTTP server](https://github.com/sphinx-doc/sphinx/blob/b6e6805f80ad530231cf841e689498005cf2bb96/tests/utils.py#L19-L30), something isn't working as expected.

cc @mindflayer (I'll likely open an issue report or two for `mocket` when I can figure out what is going on here)
Remember that using `mocket` means mocking `socket` based modules, and it has to be done in the same thread. What you can do, which is best for many testing use-cases, is using its recording mode. You'll end up with a bunch of fixtures that you can add to your repository.
See https://github.com/mindflayer/python-mocket#example-of-how-to-record-real-socket-traffic.
Thanks!  The test HTTP server does run on a separate thread, so that's likely the problem.  The recording feature looks perfect to determine whether the use of session-based requests has the intended effect.
> The test HTTP server does run on a separate thread, so that's likely the problem.

That's exactly why I mentioned that. Let me know if you need more support, I am always happy to help.
Thanks @mindflayer - I'd be grateful for your help.

I'd been planning to try switching to `aiohttp` as the test HTTP server, with the aim of handling HTTP server-and-client interaction within a single thread (and simplifying socket mocking).

Does that sound like a sensible approach, and/or do you have other suggestions?
You won't need to reach the actual server when introducing `mocket`, but `aiohttp` should work effectively as a client.
(a shorter summary of a longer draft message) Are you suggesting that instantiating a server is not necessary during these tests?
Correct, `mocket` will be responsible to fool the client and provide the response you registered.
Ok, thanks.  If possible I would like to retain the existing client/server communication during the tests, so I'm weighing up the options available.

I ran into problems using the recording mode of `mocket` with the tests as they exist today: it seems that, the server's use of sockets is interfered with after `mocket` becomes enabled (I can see the `listen`, `bind`, `accept` calls arriving on `MocketSocket`, but clearly they are not going to behave correctly for a server).

During that same attempt, there was also a problem with a call to `getsockname` before the `self._address` attribute had been assigned; I've temporarily updated [this line](https://github.com/mindflayer/python-mocket/blob/44cb5517d79b42735ff29cb84027741185348895/mocket/mocket.py#L159) locally to match [this one](https://github.com/mindflayer/python-mocket/blob/44cb5517d79b42735ff29cb84027741185348895/mocket/mocket.py#L424) (and I've read some discussion about this on your issue tracker, although I'm not yet sure whether to report this, particularly if the server-side use case is not supported).
I am not sure why would you want to use `mocket` while maintaining a client/server setup.
The main reason for using it is decoupling tests from having to talk to a "real" server (aka mocking). Some mocking libraries do that providing a fake client, `mocket` allows you to use the original client you'd use in production and it achieves it through monkey-patching the `socket` module.
#### re: socket mocks

Ok, it seems I didn't match the use-case for `mocket` correctly here, apologies for the distraction.

@mindflayer: I have some ideas about whether it might be able to support `mocket` recording mode when both client-and-server are within the same process (as here).  Is that worth reporting as a feature request, or is it too obscure a use case?  I could do some more development testing locally before creating that, to check whether the ideas are valid.


#### re: connection pool tracing

I have been able to (hackily) confirm the expected result locally by collecting a `set` of distinct connections retrieved from `urllib3.poolmanager.connection_from_url` with-and-without using `requests.Session` -- as expected (and assertable), the connection count is lower with sessions.

This did require use of (upgrade to) an HTTP/1.1 protocol server during testing -- HTTP/1.0 doesn't keep connections open by default, so the connection count does not change under HTTP/1.0.
> Is that worth reporting as a feature request, or is it too obscure a use case?

Feel free to open an issue on `mocket` side after you've done your evaluation. I'll do my best to understand the context and give you my pov on the topic.
For the linkcheck builder, since each check is a task performed by a `HyperlinkAvailabilityCheckWorker` and there is a fixed and known number of workers at the beginning of the check, one should:

- order the links by domain before submitting them to the workers. That way, we would process links by "chunks" instead of checking them one by one. 
- each worker has a dedicated session object instance. That way, the number of sessions existing simultaneously is upper-bounded by the number of maximum workers (5 by default)
- instead of submitting a single link to a worker, we should split the whole links to check as a list of chunks, each chunk representing a domain with some links to check within that specific domain. Depending on the number of links in the domain, a single worker can either process all the domain, or multiple workers share the burden of processing that domain (possibly all workers). When the tasks for the domain have been submitted, we move to the next domain and do the same with the remaining available workers. 

Ideally, if there are a lot of domains but only checking a single link everytime, the chunk approach is not good. In this case, we should do it normally. If there are a lot of links for a single domain, this would reduce the number of sessions being created.


I have a branch in progress at https://github.com/jayaddison/sphinx/tree/issue-11324/linkcheck-sessioned-requests that:

- Updates the test HTTP servers to HTTP/1.1 (enabling connection keepalive, and -- I expect -- more closely resembling the webservers that most Sphinx application instances linkcheck)
- Begins using `requests.Session` functionality
- Removes the `linkcheck_timeout` configuration (see notes below)

My changes seem naive and don't function particularly well when the tests run.

In particular: without adjusting the timeout, many of the tests fail due to timeout errors that appear in the report results:

```
(           links: line    3) broken    http://localhost:7777/ - HTTPConnectionPool(host='localhost', port=7777): Read timed out. (read timeout=0.05)
```

_With_ the timeouts removed, then most of the tests succeed, but run extremely slowly (20 seconds or so per unit test).

Running `strace` on the `pytest` process shows repeat calls to `futex` during the waiting time:

```
futex(0xa5b8d0, FUTEX_WAKE_PRIVATE, 1)  = 1
futex(0xa5b8d8, FUTEX_WAKE_PRIVATE, 1)  = 1
newfstatat(AT_FDCWD, "/tmp/pytest-of-jka/pytest-5/linkcheck/links.rst", {st_mode=S_IFREG|0644, st_size=648, ...}, 0) = 0
getpid()                                = 5395
getpid()                                = 5395
futex(0xa5b8d4, FUTEX_WAKE_PRIVATE, 1)  = 1
futex(0xa5b8d8, FUTEX_WAKE_PRIVATE, 1)  = 1
newfstatat(AT_FDCWD, "/tmp/pytest-of-jka/pytest-5/linkcheck/links.rst", {st_mode=S_IFREG|0644, st_size=648, ...}, 0) = 0
```

Socket-level networking and syscall tracing aren't things I have much expertise with, but `strace` often helps me to get a sense for where problems could exist when a userspace program is running into problems.

It's interesting to me that the tests do eventually pass -- that seems to indicate that both consumer (client) and producer (server) threads _are_ co-operating; my guesses are:

- that there are some extremely inefficient tight loops that occur along the way that near-block the threads until one or both of them receive enough CPU time to process relevant events
and/or
- that the test server's use of a limited number of sockets (todo: how many?) results in resource contention

Perhaps there's something unusual going on in the socket block/timeout configuration, and/or polling.

It feels like it should be possible to get these two threads to co-operate without these performance penalties, and then to restore the timeout configuration to ensure that the tests run quickly (in terms of elapsed time).
> I have a branch in progress at https://github.com/jayaddison/sphinx/tree/issue-11324/linkcheck-sessioned-requests that:
...
> With the timeouts removed, then most of the tests succeed, but run extremely slowly (20 seconds or so per unit test).

An additional finding: sending the `Connection: close` header as part of each response from he test HTTP/1.1 server(s) seems to achieve a large speedup in the unit test duration.
Could it be that the HTTP requests opened in streaming mode (`stream=True`) are holding a socket open until timeout?  An HTTP/1.1 server would stop sending data, but does not close the connection unless requested by the client (and, to achieve the overall network traffic goals here, we preferably _don't_ want to do that).
> Could it be that the HTTP requests opened in streaming mode (`stream=True`) are holding a socket open until timeout? An HTTP/1.1 server would stop sending data, but does not close the connection unless requested by the client (and, to achieve the overall network traffic goals here, we preferably don't want to do that).

Disabling streaming requests from the HTTP client-side here doesn't appear to affect the duration for completion of the tests.
> Could it be that the HTTP requests opened in streaming mode (stream=True) are holding a socket open until timeout?

Depends on how your server responds. If the server does not close the connection or does not send some EOF sentinel, both connections will hang until timing out (metaphorically speaking, both participants are staring at each other, waiting for the other to do something).

Concerning `requests`:

> If you set stream to True when making a request, Requests cannot release the connection back to the pool unless you consume all the data or call [Response.close](https://docs.python-requests.org/en/latest/api/#requests.Response.close). This can lead to inefficiency with connections. If you find yourself partially reading request bodies (or not reading them at all) while using stream=True, you should make the request within a with statement to ensure it’s always closed.

By the way, since we want to speed-up tests, can you actually profile what is doing most of the work (e.g., using `kernprof` and decorate functions with `@profile`) ?
Thanks @picnixz - I'll take a look at `kernprof` soon.

Introducing Python's [`socketserver.ThreadingMixin`](https://docs.python.org/3/library/socketserver.html#socketserver.ThreadingMixIn) to the test HTTP servers with its `daemon_threads` mode enabled has most of the tests passing within an acceptable duration again (https://github.com/jayaddison/sphinx/commit/cbc43ac2ba1fbd180355a9b21c2288faa2d99477).  However, there is one remaining timeout that causes a test failure: [`test_follows_redirects_on_GET`](https://github.com/jayaddison/sphinx/blob/cbc43ac2ba1fbd180355a9b21c2288faa2d99477/tests/test_build_linkcheck.py#L353-L370).

```
>       assert stderr == textwrap.dedent(
            """\
            127.0.0.1 - - [] "HEAD / HTTP/1.1" 405 -
            127.0.0.1 - - [] "GET / HTTP/1.1" 302 -
            127.0.0.1 - - [] "GET /?redirected=1 HTTP/1.1" 204 -
            """,
        )
E       assert '127.0.0.1 - - [] "HEAD / HTTP/1.1" 405 -\n127.0.0.1 - - [] "GET / HTTP/1.1" 302 -\n127.0.0.1 - - [] Request timed out: TimeoutError(\'timed out\')\n127.0.0.1 - - [] "GET /?redirected=1 HTTP/1.1" 204 -\n' == '127.0.0.1 - - [] "HEAD / HTTP/1.1" 405 -\n127.0.0.1 - - [] "GET / HTTP/1.1" 302 -\n127.0.0.1 - - [] "GET /?redirected=1 HTTP/1.1" 204 -\n'
E           127.0.0.1 - - [] "HEAD / HTTP/1.1" 405 -
E           127.0.0.1 - - [] "GET / HTTP/1.1" 302 -
E         + 127.0.0.1 - - [] Request timed out: TimeoutError('timed out')
E           127.0.0.1 - - [] "GET /?redirected=1 HTTP/1.1" 204 -

tests/test_build_linkcheck.py:363: AssertionError
```
> With the timeouts removed, then most of the tests succeed, but run extremely slowly (20 seconds or so per unit test).

FWIW: switching from the [`http.server.HTTPServer` implementation](https://github.com/sphinx-doc/sphinx/blob/e2f66cea4997b6d8c588d3509adb68d4e9108ee6/tests/utils.py#L22) to [`http.server.ThreadingHTTPServer`](https://docs.python.org/3/library/http.server.html#http.server.ThreadingHTTPServer) appeared to clear up the performance issues here.
> - each worker has a dedicated session object instance. That way, the number of sessions existing simultaneously is upper-bounded by the number of maximum workers (5 by default)

@picnixz thank you for this suggestion - I've applied it using the `conf.py` configuration in one of the test cases in the branch I'm working on, where it's configured down to one (`1`) - that's extremely helpful to assert on the number of expected connections.

I'm a little more reserved/cautious about the sorting and chunking suggestions.  Certainly it could make sense in terms of resource-usage to group together similar requests and to make them around the same time.. I think it should be a separate changeset though.  Would you like to add any more detail, or should I open that as a follow-up issue?
I'll write a separate issue this weekend. I will be offline for a few days.
Sorry @AA-Turner - #11402 doesn't complete this, could we reopen it?  It's my mistake for using the phrase `resolve #11324` in that pull request's description.
Thanks!

Most of the groundwork should be in place for this migration/feature now, I think.
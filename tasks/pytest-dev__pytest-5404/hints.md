https://github.com/feluxe/sty/blob/master/sty/primitive.py#L62-L66 is incorrect

the  problem is a bug in sty
https://github.com/feluxe/sty/issues/17
Thank you.  Since I was able to `import` without `from` it did not occur to me this could be an `sty` problem.  It feels like this is good to close since nothing can be done on your side.  Do you agree?
pytest could error better to help identifying the object or even ignore "broken" objects in the given context and only issuing a warning to take note of the issue
In this case it's actually an error from the standard library, caused by an invalid third-party library.  This is impossible to detect in general, and very hard even in "normal" cases, so IMO trying to issue a warning is impractical.
the mock aware unwrap is code in pytest that monkeypatches the stdlib
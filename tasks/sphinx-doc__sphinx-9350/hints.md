Fixed at c6c9c5c
Thank you for reporting

Apparently, I face the same problem with the latest release `4.0.2`:

index.rst:
```
Welcome to demo documentation!
==============================

This is :samp:`fine`.

Show :samp:`{problematic}` underscore starting here.

And this is also bad.
```

conf.py:
```
project = 'Demo project'
copyright = '2001-2021 XYZ'
authors = 'Me'

man_pages = [
    ('index', 'demo', 'GNU project C
```
and template Makefile is needed:

```
$ make man
man _build/man/demo.1
$ grep problematic _build/man/demo.1
Show \fB\fIproblematic\fP\fP underscore starting here.
```

![Screenshot from 2021-06-15 22-00-24](https://user-images.githubusercontent.com/2658545/122115842-2aac9f80-ce25-11eb-867c-b479b076fe92.png)
Apparently, it's problematic only when a `:samp:` directive begins with `{`. I've got a patch for it.
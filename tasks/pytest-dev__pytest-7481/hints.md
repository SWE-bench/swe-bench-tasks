Hmmm at first glance doesn't seem related to pytest 6 and this is a bug which has always been there, but I might be wrong of course.

Can you try to make a test which always fails and outputs that emoji? Also would help if you can try with and without instafail. 
Will do so, but might be next week until I get to it, as I'm giving a pytest training on Mon/Tue/Wed :slightly_smiling_face: 
No problems! 👍 
From the stacktrace it looks like the stdout encoding is `cp1252` which I think even for Windows is pretty limited. Looks like [since Python 3.6](https://www.python.org/dev/peps/pep-0528/) the Windows Console encoding is supposed to be UTF-8, and you are running on Python 3.7 so I wonder why that is.
Hi there, we're also seeing this issue in builds under Linux and Mac.

For us, it's complaining about the unicode checkmark:

```
INTERNALERROR> UnicodeEncodeError: 'ascii' codec can't encode character '\u2713' in position 7: ordinal not in range(128)
 ```

and it's doing it when a plugin we're using ([pytest-it](https://pypi.org/project/pytest-it/) ) is reporting success (and using the unicode checkmark).

I was going to make a test repo isolating the problem, but it'll basically just be what I said here. Would you like it as it's own issue when I do, or do you think it's related to this?

FWIW, rolling back our projects to 5.4.3 makes this issue go away. It only happens in the 6.x-rc from last night.
> FWIW, rolling back our projects to 5.4.3 makes this issue go away. It only happens in the 6.x-rc from last night.

This is an important confirmation, thanks!
Also if someone can provide a simple reproducible example/repo on Windows I will be happy to take a look since I'm on Windows. 👍 
@criswell I tried to reproduce locally but it works OK here. Under which environment does this happen?
I can reproduce something similar on Linux:

```
INTERNALERROR>   File "/home/florian/proj/pytest/src/_pytest/_io/terminalwriter.py", line 245, in write
INTERNALERROR>     self._file.write(markupmsg)
INTERNALERROR> UnicodeEncodeError: 'ascii' codec can't encode character '\U0001f300' in position 8: ordinal not in range(128)
```

with

```python
def func(text):
    assert False

def test_func():
    func('\U0001f300')
```

and `PYTHONIOENCODING=ascii pytest test_unicode.py`. Slightly contrived, but I suspect the real-world cases we're seeing are similar: Python probably doesn't have an Unicode terminal on GitHub Actions and Windows (since it's not a real TTY) and I'm guessing @criswell is using Python < 3.7 before [PEP 538](https://www.python.org/dev/peps/pep-0538/) with a misconfigured locale (`LC_CTYPE=C` or similar).

Bisected to b6cc90e0afe90c84d84c5b15a2db75d87a2681d7 / #7135 ("terminalwriter: remove support for writing bytes directly")


Aha! Yes, this is happening on CircleCI... it very easily could be a misconfigured locale.

I've been trying to reproduce it in my own test repo, https://github.com/criswell/pytest-tests/pull/1 , and it's been working fine. But there, it's GitHub actions so it could be getting correct locale settings.

Let me try with some of our internal repos where we encountered this issue and see.

*Edit*: And, on our internal repos we've standardized on python 3.6.9, so the pre PEP-538 checks out.
Thanks for bisecting @The-Compiler! The commit makes perfect sense, I already forgot about it!

So that commit message is a bit misleading in that it does two things:

1. Remove support for writing `bytes` directly -- this is good, pytest doesn't do it.

2. Removed this logic which handles various levels of brokenness in the console:

```py

def write_out(fil, msg):
    # XXX sometimes "msg" is of type bytes, sometimes text which
    # complicates the situation.  Should we try to enforce unicode?
    try:
        # on py27 and above writing out to sys.stdout with an encoding
        # should usually work for unicode messages (if the encoding is
        # capable of it)
        fil.write(msg)
    except UnicodeEncodeError:
        # on py26 it might not work because stdout expects bytes
        if fil.encoding:
            try:
                fil.write(msg.encode(fil.encoding))
            except UnicodeEncodeError:
                # it might still fail if the encoding is not capable
                pass
            else:
                fil.flush()
                return
        # fallback: escape all unicode characters
        msg = msg.encode("unicode-escape").decode("ascii")
        fil.write(msg)
    fil.flush()
```

I believe what that code did for you and @criswell is:

1. `fil.write(msg)` fails with `UnicodeEncodeError` (=> what is now propagated, reported in this issue)
2. `msg.encode(fil.encoding)` also raises `UnicodeEncodeError` (this attempt is really quite redundant I guess on Python>2.6)
3. The `msg.encode("unicode-escape").decode("ascii")` path is taken which can't fail. This turns e.g. `'🌀'` to `'\\U0001f300'`.

(To confirm this, will be nice to get a CI run on python 5.4 if you can link one).

Overall I think this error is a *good thing* because in 2020 there is not much reason to have a stdout which doesn't support Unicode. 99% of the time this indicates a misconfigured environment, and it is better to fix it than to silently get ugly confusing output like `\U0001f300`.

WDYT? Should we bring the escaping back or stick to our guns? (If we do, I'll make sure to highlight this in the changelog and lay out possible reasons and fixes; it's completely missing now).
IMHO, this is a clear bug in pytest. A test runner definitely should not fail with an internal error (which is quite confusing if you don't know what's going on) when a test fails. We handle quite some esoteric cases (with `safe_repr` and all), this one seems rather common in comparison.
Do you mean that the bug is that the error message is unclear (we can probably improve on that), or that the error happens at all?

To me the previous behavior is actually buggy - some unicode character is printed, but something else is displayed instead.
I think pytest should defer to whichever way Python configured stdout (e.g. `strict` error handler), and I think pytest shouldn't try to workaround a broken environment, but instead encourage the user to fix it:

- Fix the locale, otherwise
- Use a newer Python, otherwise
- Set `PYTHONIOENCODING`, otherwise
- Avoid printing strings that are not supported by your environment
But it's pytest printing that string, not my code/test... If that was the case I would agree.

So this:

> Avoid printing strings that are not supported by your environment

Is what pytest should do (and did before that change). :wink:
Internally our docker images which run our pytest code are apparently setting the locale settings to `POSIX`, which, I would argue, doesn't necessarily mean it's incapable of printing unicode (in fact, they can and have done so with previous versions of pytest). I'll be working to get them set to something more PEP-538 friendly to harden them against similar issues in the future.

That being said, I actually agree that this could be handled more gracefully inside of pytest. For us, it was a plugin printing a unicode character using terminalwriter. Plugins can't be expected to figure out if the environment is set properly for what they are trying to log, that should be pytest's job.

~generally the best way to handle this is to either use `io.TextIOWrapper(..., encoding='UTF-8')` or directly write to `file.buffer` with bytes -- here's (for example) [how pre-commit handles this](https://github.com/pre-commit/pre-commit/blob/2f1d4d10e0918c07935ae53ae743efbc9e9bd4eb/pre_commit/output.py#L8-L10)

without `LANG` set (on posixlike platforms), python will default to `US-ASCII` encoding (which is what's causing the `ascii` default on GA / others).  on windows, CMD (and older powershell) will default to cp1252.

In 2020, it's probably reasonable to always write UTF-8 bytes
@asottile Note that pytest still needs to run on Python 3.5 on Windows (i.e. pre-[PEP 528](https://www.python.org/dev/peps/pep-0528/)). No idea what happens if you output raw utf-8 there, but I bet that's not going to go well.

I still think the previous `"unicode-escape"` encoding was a great solution, even more so in scenarios like my test above where pytest tries to print `text = '🌀'`, i.e. a Python string. For the most majority of the cases (Python 3.6+ in almost all cases) we will get UTF-8 output anyways thanks to [PEP-528](https://www.python.org/dev/peps/pep-0528/) and [PEP-538](https://www.python.org/dev/peps/pep-0538/), and in all other cases we still produce a meaningful output (in which it's still clear what character that was) instead of mojibake.
While I can sympathize with @bluetech's sentiment of exposing the misconfiguration, unfortunately I think we should get back escape strings here. This example by @The-Compiler nails it down for me: 

```python
def func(text):
    assert False

def test_func():
    func('\U0001f300')
```

The user is not even printing to the console, so it is not helpful that pytest breaks because it is writing to the console, and worse only when the test fails, making the problem possibly go silent and blowing up much later on a different host.

So 👍 from me to escape this again (about *how* to do it I don't have a strong opinion).
OK, I'll bring back the escaping, especially because I failed to mention this change it in the commit/changelog.

(Note: I changed the issue title `UncodeDecodeError` -> `UnicodeEncodeError`).
[GitMate.io](https://gitmate.io) thinks possibly related issues are https://github.com/pytest-dev/pytest/issues/3346 (Please error when fixtures conflict), https://github.com/pytest-dev/pytest/issues/2872 (mark fixtures ), https://github.com/pytest-dev/pytest/issues/2399 (marks should propogate through fixtures), https://github.com/pytest-dev/pytest/issues/2424 (dynamically generated fixtures), and https://github.com/pytest-dev/pytest/issues/3351 (Is there a way to provide mark with fixture params).
@nicoddemus I am starting working on this.
Great, thanks @avirlrma! 
@nicoddemus I'm having trouble with code navigation, need some help with it. My initial guess was `mark/evaluate.py`, but it is called even when there are no marked tests.
I am using a test like below and and setting up breakpoints to find where the `@pytest.mark.usefixtures('client')` takes me but I'm having no luck with the same.
```
import pytest

@pytest.fixture
def client():
    print('fixture.client')


@pytest.mark.usefixtures('client')
def test_tom():
    print('user jessie')
    assert 0
```
Hi @avirlrma,

Actually I believe you need to look at where marks are applied to functions; at that point we need to identify if the function where the mark will be applied is already a fixture (possibly by checking one of the attributes which are attached to the function by the `fixture` decorator).

(Sorry for the brevity as I'm short on time)
the pytest fixture parser should raise an error if either the fuction or the wrapped function has markers applied
@RonnyPfannschmidt @nicoddemus Where should we catch the error? I mean when fixture is parsed or when the marks are applied to function?

Also,
```
@pytest.fixture
@pytest.mark.usefixtures('client')
def user_tom():
    print('user jessie')

```
As far as I understand decorators, mark will applied first, but since then the function is not a fixture, this should work, but it doesn't. Please help me with this as well.
> Where should we catch the error?

You mean raise the error? We don't need to catch the error, only raise it to warn the user.

> I mean when fixture is parsed or when the marks are applied to function?

Probably at both places, because as you correctly point out, marks and fixtures can be applied in different order.

Btw, perhaps we should issue a warning instead of an error right away? 
Ah yes, I meant raise the error. 
I am working on finding the code for fixtures are parsed and marks are applied. May need some help on that later.
>  we should issue a warning instead of an error right away?

How do we do that?
we should check both, fixture, and at fixture parsing time, as we currently still need to catch stuff like 
```python

@pytest.mark.usefixtures('client')
@pytest.fixture
def user_tom():
    print('user jessie')
```
ok, so we have to check both. For now I'm starting with the mark first and then fixture case i.e.:
```
@pytest.fixture
@pytest.mark.usefixtures('client')
```
This can be raised when the fixture is parsed, so the necessary changes will be done in `fixtures.py` . Let me know If you find something wrong with the approach.
Just need explanation on the warning thing @nicoddemus talked about above.
> Let me know If you find something wrong with the approach.

Sounds good, we can discuss over a PR.

> Just need explanation on the warning thing @nicoddemus talked about above.

I mean to issue a warning instead of an error, something like:

```python
warnings.warn(pytest.PytestWarning('marks cannot...'), stacklevel=2)
```
got it! I'm working on the PR
I don't understand why applying the `usefixtures` marker to a fixture should result in an error.
Fixtures can already use other fixtures by declaring them in the signature:
```python
@pytest.fixture
def setup_for_bar():
    # setup something....
    pass

@pytest.fixture
def bar(setup_for_bar):
    return 43
```

What is the reason of *not* supporting the equivalent way with `usefixtures`?
```python
@pytest.fixture
def setup_for_bar():
    # setup something....
    pass

@pytest.mark.usefixtures('setup_for_bar')
@pytest.fixture
def bar():
    return 43
```

The reason I am asking this is that in pytest-factoryboy we have to call [exec](https://github.com/pytest-dev/pytest-factoryboy/blob/a873a8f5d101d4d3d7956c2b4e9d15b28b98c3f5/pytest_factoryboy/fixture.py#L42) in order to generate a fixture that requires all the relevant fixtures. The use of `exec` could be easily avoided if it was possible to mark a fixture with the `usefixtures` marker.

EDIT: I made a typo that changed the polarity of the sentence "What is the reason of *not* supporting the equivalent way with `usefixtures`?"
Hi @youtux, 

> I don't understand why applying the usefixtures marker to a fixture should result in an error.

Mostly because it doesn't do anything currently.

> What is the reason of supporting the equivalent way with usefixtures? 

This issue is about raising an error if a mark is aplied to a fixture, not to support `@pytest.mark.usefixtures` in fixtures. 😁 
Sorry, I meant to say "What is the reason of **not** supporting the equivalent way with usefixtures?". So I am all about supporting it, not the other way around 😅.
Oh OK! 😁 

I think it makes sense actually; this task is more of a stop gap in order for people to stop using it and it doing nothing I think. It is easier to remove this when we eventually do support marks in fixtures.
So if I understand correctly this is just about making it resulting into an error, but the maintainers are not against this feature per-se, correct?
I don't think so; previously it was a problem technically because of how marks worked internally, but since we have refactor and improved that aspect I think it should be fine to do this now.
Ok, I'll give it a look then.
Thanks!
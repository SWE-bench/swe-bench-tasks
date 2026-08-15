Yeah, it looks like this code never anticipated the possibility that a later warning might be a better match than the current warning.  That said, we need to preserve the current behavior of matching if the warning was a subclass, so instead of the current

```python
for i, w in enumerate(self._list):
    if issubclass(w.category, cls):
        return self._list.pop(i)
```
I propose we do something like
```python
# Match the first warning that is a subtype of `cls`, where there
# is *not* a later captured warning which is a subtype of this one.
matches = []
for i, w in enumerate(self._list):
    if w.category == cls:  # in this case we can exit early
        return self._list.pop(i)
    if issubclass(w.category, cls):
        matches.append((i, w))
if not matches:
    raise ... # see current code for details
(idx, best), *rest = matches
for i, w in rest:
    if issubclass(w, best) and not issubclass(best, w):
        idx, best = i, w
return self._list.pop(idx)
```

and it would be awesome if you could open a PR with this, tests, a changelog entry, and of course adding yourself to the contributors list 🙏 
Thank you for your comments @Zac-HD. Let me start by describing the challenge I am trying to work out in my code. I have a function that returns several warnings, and I want to check that for a certain set of arguments, all the expected warnings are emitted. This would mean checking that the proper warning classes have been captured and a matched portion of the warning message is also present. In an ideal world, I would think my test would probably look like:
```python
def test_warnings():
    with pytest.warns(RWarning) as record:   # RWarning is the base warning class for the library and all other warning inherit from it
        my_function('a', 'b')
    assert len(record) == 2
    assert record.contains(RWarning, match_expr="Warning2") # this would be looking explicitly for RWarning, not its subclasses
    assert record.contains(SWarning, match_expr="Warning1")
```
I was thinking about this more and testing the code you wrote and feel that maybe a separate method would be a better solution.

My ideas are:
1. a `.contains` method that does exact class checking. True if specified warning exists (and if an optional match_expr matches the warning message). See above for possible usage example.  Returns True/False
Possible implementation
```python
def contains(self, cls, match_expr=None):
    if match_expr:
        match_re = re.compile(match_expr)
        for w in self._list:
            if w.category is cls and match_re.search(str(w.message)):
                return True
    else:
        for w in self._list:
            if w.category is cls:
                return True
    return False
```
2. a `.search` or `.findall` (inspired by the regex library) method that can do strict or subclass checking with a keyword argument switch. Returns a list of matching warnings. This could also do message matching, if desired.
```python
m = list(record.match(RWarning, subclasses=False)) # do exact class matching
m = list(record.match(RWarning, subclasses=True)) # match with classes that are RWarnings or where RWarning is a base class
```
Possible implentation:
```python
def match(self, cls, subclasses=False):
    """ Match cls or cls subclasses """
    if subclasses:
        op = issubclass
    else:
        op = operator.is_
	
    for i, w in enumerate(self._list):
	if op(w.category, cls):
            yield i

# Then .pop becomes
def pop(self, cls):
    try:
        i = next(self.match(cls, subclasses=True))
        return self._list.pop(i)
    except StopIteration:
        __tracebackhide__ = True
        raise AssertionError(f"{cls!r} not found in warning list")
```

What are your thoughts, @Zac-HD?
Seems like you might be better of with [the stdlib `with warnings.catch_warnings(record=True, ...) as list_of_caught_warnings:`](https://docs.python.org/3/library/warnings.html#testing-warnings) function, and making assertions manually?

Pytest helpers are nice, but sometimes it's worth using the rest of Python instead 😁 
It does remind me of the plan to integrate dirty equals better into pytest, it would be nice if there was a way to spell the warning matches for the contains check 
Yeah, it looks like this code never anticipated the possibility that a later warning might be a better match than the current warning.  That said, we need to preserve the current behavior of matching if the warning was a subclass, so instead of the current

```python
for i, w in enumerate(self._list):
    if issubclass(w.category, cls):
        return self._list.pop(i)
```
I propose we do something like
```python
# Match the first warning that is a subtype of `cls`, where there
# is *not* a later captured warning which is a subtype of this one.
matches = []
for i, w in enumerate(self._list):
    if w.category == cls:  # in this case we can exit early
        return self._list.pop(i)
    if issubclass(w.category, cls):
        matches.append((i, w))
if not matches:
    raise ... # see current code for details
(idx, best), *rest = matches
for i, w in rest:
    if issubclass(w, best) and not issubclass(best, w):
        idx, best = i, w
return self._list.pop(idx)
```

and it would be awesome if you could open a PR with this, tests, a changelog entry, and of course adding yourself to the contributors list 🙏 
Thank you for your comments @Zac-HD. Let me start by describing the challenge I am trying to work out in my code. I have a function that returns several warnings, and I want to check that for a certain set of arguments, all the expected warnings are emitted. This would mean checking that the proper warning classes have been captured and a matched portion of the warning message is also present. In an ideal world, I would think my test would probably look like:
```python
def test_warnings():
    with pytest.warns(RWarning) as record:   # RWarning is the base warning class for the library and all other warning inherit from it
        my_function('a', 'b')
    assert len(record) == 2
    assert record.contains(RWarning, match_expr="Warning2") # this would be looking explicitly for RWarning, not its subclasses
    assert record.contains(SWarning, match_expr="Warning1")
```
I was thinking about this more and testing the code you wrote and feel that maybe a separate method would be a better solution.

My ideas are:
1. a `.contains` method that does exact class checking. True if specified warning exists (and if an optional match_expr matches the warning message). See above for possible usage example.  Returns True/False
Possible implementation
```python
def contains(self, cls, match_expr=None):
    if match_expr:
        match_re = re.compile(match_expr)
        for w in self._list:
            if w.category is cls and match_re.search(str(w.message)):
                return True
    else:
        for w in self._list:
            if w.category is cls:
                return True
    return False
```
2. a `.search` or `.findall` (inspired by the regex library) method that can do strict or subclass checking with a keyword argument switch. Returns a list of matching warnings. This could also do message matching, if desired.
```python
m = list(record.match(RWarning, subclasses=False)) # do exact class matching
m = list(record.match(RWarning, subclasses=True)) # match with classes that are RWarnings or where RWarning is a base class
```
Possible implentation:
```python
def match(self, cls, subclasses=False):
    """ Match cls or cls subclasses """
    if subclasses:
        op = issubclass
    else:
        op = operator.is_
	
    for i, w in enumerate(self._list):
	if op(w.category, cls):
            yield i

# Then .pop becomes
def pop(self, cls):
    try:
        i = next(self.match(cls, subclasses=True))
        return self._list.pop(i)
    except StopIteration:
        __tracebackhide__ = True
        raise AssertionError(f"{cls!r} not found in warning list")
```

What are your thoughts, @Zac-HD?
Seems like you might be better of with [the stdlib `with warnings.catch_warnings(record=True, ...) as list_of_caught_warnings:`](https://docs.python.org/3/library/warnings.html#testing-warnings) function, and making assertions manually?

Pytest helpers are nice, but sometimes it's worth using the rest of Python instead 😁 
It does remind me of the plan to integrate dirty equals better into pytest, it would be nice if there was a way to spell the warning matches for the contains check 
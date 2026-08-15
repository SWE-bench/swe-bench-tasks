Perhaps the messaging can be changed from "Pattern" to "Regex" or "Regex pattern" to make it more clear?  I'm not sure a warning for strings is appropriate here (unless we want to remove that functionality) since the api allows strings
A check for exact equality + a value error on forgotten regex escape may prevent some headscratching
It's not about disallowing strings, or warning for all strings. It's more that because it is a pattern library, any string using parenthesis needs to have them escaped, unless they are deliberate regex strings. It should also only be before the failed assertion.

I did understand the message eventually. It is more that the display of the message showing two identical strings gave me pause for thought.

Having two kwargs was something I looked for, but didn't find anything about. One for strings, one for patterns as that would have allowed me to avoid the escaping altogether.
parens are valid in regexes as grouping so they can't be warned on / banned outright

I usually find an exact match better anyway:

```python
with pytest.raises(T) as excinfo:
    ...
msg, = excinfo.value.args
assert msg == ...
```
Please re-read what I am proposing. This is not about banning

1. > It's not about disallowing strings, or warning for all strings.

    It's not even about warnings for any string with parenthesis. It is about contextually highlighting to people "Hey, this thing believe's you've sent it a regex. Did you mean to?" in the case that both _expected_ and _actual_ are identical.

    One alternative is to use or to regex match and perform string comparison. Please look at the example given.

    ```python
    any([
        actual == expected,
        regex.match(expected)
    ])
    ```
2. >  It's more that because it is a pattern library, any string using parenthesis needs to have them escaped, unless they are deliberate regex strings.

      this agree's with your statement @asottile 
3. >  It should also only be before the failed assertion.

    So in the case of this assertion failing. If it has unescaped parenthesis, or any one of many characters
4. If I supply this keyword argument with a string with parenthesis at the moment, it treats them as a regex matching group, which they are not. That was the situation that led to this and is present in the reproduction example.
Other things I am not suggesting

* Checking exceptions for details is a particularly good method of exception usage. I far prefer specific exception classes with internal logging.
* This is the only solution.
  * I saw the suggestion https://github.com/pytest-dev/pytest/issues/7489#issuecomment-657717070, but think it is still very wordy
  * I've proposed an alternative above
  * I proposed another alternative with warnings to separate the error message from potentially lengthy hints

I'm merely attempting to address something that tripped me up, that I feel has likely tripped up others who may not have reported any issue, or moved on from.


@asottile What i was suggesting is a better error when the is value equal to the regex but would not match it 
> One alternative is to use or to regex match and perform string comparison

I don't think this is a good idea, because I may want to pass an actual regex which happens to be string-equal but not regex-match.

I think we can improve in these ways:

1. If string-equal, but not regex-match, show a "Did you mean" help message (as suggested by @RonnyPfannschmidt).
2. Change "Pattern ..." to "Regex pattern ..." (as suggested by @asottile).
3. Prefix `r` to the regex pattern, as another visual indicator that it's a regex. (It would need to actually be valid of course).

WDYT?
Looking at the code 

https://github.com/pytest-dev/pytest/blob/master/src/_pytest/python_api.py

I don't see the error message. Is it calling a matcher from within pytest which is wrapped around the exception somewhere I'm not glancing?
@Lewiscowles1986, yes, the check is done here:

https://github.com/pytest-dev/pytest/blob/7f7a36478abe7dd1fa993b115d22606aa0e35e88/src/_pytest/_code/code.py#L605-L616
> Prefix r to the regex pattern, as another visual indicator that it's a regex. (It would need to actually be valid of course).

everything else I agree with but this is 🙅‍♂️ -- (1) raw strings have nothing to with regexes despite both starting with the letter `r` -- please don't conflate them (2) it's not a trivial task to convert a string variable into a representation of a raw string literal
I never suggested the `r` prefix would make a regex valid or make a string a regex... Why the hot-takes?

The `r` modifier is specifically so that the invalid escape code message is avoided and PEP is not violated when dealing with a string that is used by this. I've not suggested it magically makes regexes and I've not authored a library that takes a string and decides it's a regex, complicating literal match use-cases.
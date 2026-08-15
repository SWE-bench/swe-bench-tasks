Hi @ppavril, thanks for raising this issue!

So the problem here is that we don't ask for a string representation of keys or values. I think the correct fix is changing the following code (at [line 102 of models.py](https://github.com/kennethreitz/requests/blob/master/requests/models.py#L102)) from:

``` python
for field, val in fields:
    if isinstance(val, basestring) or not hasattr(val, '__iter__'):
        val = [val]
    for v in val:
        if v is not None:
            new_fields.append(
                (field.decode('utf-8') if isinstance(field, bytes) else field,
                 v.encode('utf-8') if isinstance(v, str) else v))
```

to:

``` python
for field, val in fields:
    if isinstance(val, basestring) or not hasattr(val, '__iter__'):
        val = [val]
    for v in val:
        if v is not None:
            if not isinstance(v, basestring):
                v = str(v)

            new_fields.append(
                (field.decode('utf-8') if isinstance(field, bytes) else field,
                 v.encode('utf-8') if isinstance(v, str) else v))
```

However, this is a breaking API change (we now coerce non-string types in the data dict), so should become part of #1459. We should also take advantage of that to clean this section of code up, because it's not totally easy to follow.

In the meantime @ppavril, you can work around this by calling `str()` on all your data values before passing them to Requests.

Thank you for your quick answer.
I think remaining on 1.2.0 version now and look at your improvements and chagement when I'll upgrade.
Thanks,

Funny thing. I misread @Lukasa's snippet and typed out this whole response as to why it was not optimal then looked at it again and deleted it. :-) 

I rewrote that snippet twice. =P

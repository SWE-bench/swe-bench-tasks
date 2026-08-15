This incredibly unhelpful exception is sometimes thrown because the URL is invalid. For example:

``` python
>>> u'google.com'.encode('idna')
'google.com'
>>> u'.google.com'.encode('idna')
UnicodeError: label empty or too long
```

Would it be possible for you to check the URL you're using, or alternatively to post it here so I can take a look?

@terrycojones Is this bug still affecting you, or has it been resolved?

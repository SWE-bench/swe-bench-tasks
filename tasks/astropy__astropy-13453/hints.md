Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/main/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

GitHub issues in the Astropy repository are used to track bug reports and feature requests; If your issue poses a question about how to use Astropy, please instead raise your question in the [Astropy Discourse user forum](https://community.openastronomy.org/c/astropy/8) and close this issue.

If you feel that this issue has not been responded to in a timely manner, please leave a comment mentioning our software support engineer @embray, or send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
The format has to be one of the accepted values listed in https://docs.astropy.org/en/stable/io/unified.html#built-in-table-readers-writers . I am surprised it didn't crash though.
Ah, wait, it is "formats", not "format". Looks like it might have picked up `ascii.html`, which I think leads to this code here that does not take `formats`:

https://github.com/astropy/astropy/blob/19cc80471739bcb67b7e8099246b391c355023ee/astropy/io/ascii/html.py#L342

Maybe @taldcroft , @hamogu , or @dhomeier can clarify and correct me.
@mattpitkin - this looks like a real bug thanks for reporting it. 

You can work around it for now by setting the format in the columns themselves, e.g.
```
>>> tc['a'].info.format = '.1e'
>>> from astropy.io import ascii
>>> tc.write('table.html', format='html')
>>> !cat table.html
<html>
 <head>
  <meta charset="utf-8"/>
  <meta content="text/html;charset=UTF-8" http-equiv="Content-type"/>
 </head>
 <body>
  <table>
   <thead>
    <tr>
     <th>a</th>
     <th>b</th>
    </tr>
   </thead>
   <tr>
    <td>1.2e-24</td>
    <td>2</td>
   </tr>
   <tr>
    <td>3.2e-15</td>
    <td>4</td>
   </tr>
  </table>
 </body>
</html>
```


As an aside, you don't need to use the lambda function for the `formats` argument, it could just be 
```
tc.write(sp, format="csv", formats={"a": ".2e"})
```

Thanks for the responses.

It looks like the problem is that here https://github.com/astropy/astropy/blob/main/astropy/io/ascii/html.py#L433

where it goes through each column individually and get the values from `new_col.info.iter_str_vals()` rather than using the values that have been passed through the expected formatting via the `str_vals` method:

https://github.com/astropy/astropy/blob/main/astropy/io/ascii/core.py#L895

I'll have a look if I can figure out a correct procedure to fix this and submit a PR if I'm able to, but I'd certainly be happy for someone else to take it on if I can't.
In fact, I think it might be as simple as adding:

`self._set_col_formats()`

after line 365 here https://github.com/astropy/astropy/blob/main/astropy/io/ascii/html.py#L356.

I'll give that a go.
I've got it to work by adding:

```python
# set formatter
for col in cols:
    if col.info.name in self.data.formats:
        col.info.format = self.data.formats[col.info.name]
```

after line 365 here https://github.com/astropy/astropy/blob/main/astropy/io/ascii/html.py#L356.

An alternative would be the add a `_set_col_formats` method to the `HTMLData` class that takes in `cols` as an argument.

I'll submit a PR.
Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/main/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

GitHub issues in the Astropy repository are used to track bug reports and feature requests; If your issue poses a question about how to use Astropy, please instead raise your question in the [Astropy Discourse user forum](https://community.openastronomy.org/c/astropy/8) and close this issue.

If you feel that this issue has not been responded to in a timely manner, please leave a comment mentioning our software support engineer @embray, or send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
The format has to be one of the accepted values listed in https://docs.astropy.org/en/stable/io/unified.html#built-in-table-readers-writers . I am surprised it didn't crash though.
Ah, wait, it is "formats", not "format". Looks like it might have picked up `ascii.html`, which I think leads to this code here that does not take `formats`:

https://github.com/astropy/astropy/blob/19cc80471739bcb67b7e8099246b391c355023ee/astropy/io/ascii/html.py#L342

Maybe @taldcroft , @hamogu , or @dhomeier can clarify and correct me.
@mattpitkin - this looks like a real bug thanks for reporting it. 

You can work around it for now by setting the format in the columns themselves, e.g.
```
>>> tc['a'].info.format = '.1e'
>>> from astropy.io import ascii
>>> tc.write('table.html', format='html')
>>> !cat table.html
<html>
 <head>
  <meta charset="utf-8"/>
  <meta content="text/html;charset=UTF-8" http-equiv="Content-type"/>
 </head>
 <body>
  <table>
   <thead>
    <tr>
     <th>a</th>
     <th>b</th>
    </tr>
   </thead>
   <tr>
    <td>1.2e-24</td>
    <td>2</td>
   </tr>
   <tr>
    <td>3.2e-15</td>
    <td>4</td>
   </tr>
  </table>
 </body>
</html>
```


As an aside, you don't need to use the lambda function for the `formats` argument, it could just be 
```
tc.write(sp, format="csv", formats={"a": ".2e"})
```

Thanks for the responses.

It looks like the problem is that here https://github.com/astropy/astropy/blob/main/astropy/io/ascii/html.py#L433

where it goes through each column individually and get the values from `new_col.info.iter_str_vals()` rather than using the values that have been passed through the expected formatting via the `str_vals` method:

https://github.com/astropy/astropy/blob/main/astropy/io/ascii/core.py#L895

I'll have a look if I can figure out a correct procedure to fix this and submit a PR if I'm able to, but I'd certainly be happy for someone else to take it on if I can't.
In fact, I think it might be as simple as adding:

`self._set_col_formats()`

after line 365 here https://github.com/astropy/astropy/blob/main/astropy/io/ascii/html.py#L356.

I'll give that a go.
I've got it to work by adding:

```python
# set formatter
for col in cols:
    if col.info.name in self.data.formats:
        col.info.format = self.data.formats[col.info.name]
```

after line 365 here https://github.com/astropy/astropy/blob/main/astropy/io/ascii/html.py#L356.

An alternative would be the add a `_set_col_formats` method to the `HTMLData` class that takes in `cols` as an argument.

I'll submit a PR.
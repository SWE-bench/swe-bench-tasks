Hi! I would like to work in this issue :)

@eamanu thanks for volunteering! Please go ahead and let us know if you encounter any problems. 👍 
Hi can I work on this as well ? 
Hi, @wassafshahzad sure!! I looked into the pytest code to identify where that message is write. That is here [0], I spend several time trying to found where the name  is "loaded" into a class that use the NodeMeta. But I cannot found nothing yet. So, I'm trying to access to the Node class [1]  variables from NodeMeta, and I guess that we'll need to use  `inspect` to get the "path" to the bad initialize class. 

[0] https://github.com/pytest-dev/pytest/blob/6247a956010855f227181ba6167c89bb500e9480/src/_pytest/nodes.py#L122
[1] https://github.com/pytest-dev/pytest/blob/6247a956010855f227181ba6167c89bb500e9480/src/_pytest/nodes.py#L146
Hi @eamanu @wassafshahzad,

Classes have a `__module__` attribute which contain exactly the string we need:

```python
>>> from _pytest.nodes import File
>>> File.__module__
'_pytest.nodes'
``` 

So unless I'm missing something it is just a matter of changing:

https://github.com/pytest-dev/pytest/blob/6247a956010855f227181ba6167c89bb500e9480/src/_pytest/nodes.py#L126

To:

```python
).format(name=f"{self.__module__}.{self.__name__}")
```
> Hi @eamanu @wassafshahzad,
> 
> Classes have a `__module__` attribute which contain exactly the string we need:
> 
> ```python
> >>> from _pytest.nodes import File
> >>> File.__module__
> '_pytest.nodes'
> ```
> 
> So unless I'm missing something it is just a matter of changing:
> 
> https://github.com/pytest-dev/pytest/blob/6247a956010855f227181ba6167c89bb500e9480/src/_pytest/nodes.py#L126
> 
> To:
> 
> ```python
> ).format(name=f"{self.__module__}.{self.__name__}")
> ```

so should we create a PR with this change ? 
Yes pretty much. 😁 

Make sure to add/update an existing test for the new behavior too.
@keewis Could you check this please? I think this is related to convert_numpy_type_spec.
`napoleon` converts the docstring to
```rst
Establish a shared lock to the resource.

:Parameters: * **timeout** (:class:`Union[float`, :class:`Literal[```"default"``:class:`]]`, *optional*) -- Absolute time period (in milliseconds) that a resource waits to get
               unlocked by the locking session before returning an error.
               Defaults to "default" which means use self.timeout.
             * **requested_key** (:class:`Optional[str]`, *optional*) -- Access key used by another session with which you want your session
               to share a lock or None to generate a new shared access key.

:returns: *str* -- A new shared access key if requested_key is None, otherwise, same
          value as the requested_key
```
which I guess happens because I never considered typehints when I wrote the preprocessor. To be clear, type hints are not part of the format guide, but then again it also doesn't say they can't be used.

If we allow type hints, we probably want to link those types and thus should extend the preprocessor. Since that would be a new feature, I guess we shouldn't include that in a bugfix release.

For now, I suggest we fix this by introducing a setting that allows opting out of the type preprocessor (could also be opt-in).
Faced the same issue in our builds yesterday.

```
Warning, treated as error:
/home/travis/build/microsoft/LightGBM/docs/../python-package/lightgbm/basic.py:docstring of lightgbm.Booster.dump_model:12:Inline literal start-string without end-string.
```

`conf.py`: https://github.com/microsoft/LightGBM/blob/master/docs/conf.py
 Logs: https://travis-ci.org/github/microsoft/LightGBM/jobs/716228303

One of the "problem" docstrings: https://github.com/microsoft/LightGBM/blob/ee8ec182010c570c6371a5fc68ab9f4da9c6dc74/python-package/lightgbm/basic.py#L2762-L2782

that's a separate issue: you're using a unsupported notation for `default`. Supported are currently `default <obj>` and `default: <obj>`, while you are using `optional (default=<obj>)`. To be fair, this is currently not standardized, see numpy/numpydoc#289.

Edit: in particular, the type preprocessor chokes on something like `string, optional (default="split")`, which becomes:
```rst
:class:`string`, :class:`optional (default=```"split"``:class:`)`
```
so it splits the default notation into `optional (default=`, `"split"`, and `)`

However, the temporary fix is the same: deactivate the type preprocessor using a new setting. For a long term fix we'd first need to update the `numpydoc` format guide.

@tk0miya, should I send in a PR that adds that setting?
@keewis Yes, please.

>If we allow type hints, we probably want to link those types and thus should extend the preprocessor. Since that would be a new feature, I guess we shouldn't include that in a bugfix release.

I think the new option is needed to keep compatibility for some users. So it must be released as a bugfix release. So could you send a PR to 3.2.x branch? I'm still debating which is better to enable or disable the numpy type feature by default. But it should be controlled via user settings.
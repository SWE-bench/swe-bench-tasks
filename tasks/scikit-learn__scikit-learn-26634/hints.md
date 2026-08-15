Hi @yotamcons, the ``fit_transform`` method of NMF does not expose the option ``update_H``. It's the private method ``_fit_transform`` that does expose it, but it's there for internal purpose, so it's advised not to call it directly. I f you really want to use it, you need to set n_components appropriately.
Sorry for the misleading writing, the problem is that `non_negative_factorization` internally calls `_fit_transform` and causes the said issue. I've edited the issue to make it clearer.
Thanks for the clarification. Indeed, we check that the shape are consistent. `n_components` is only determined by the `n_components` parameter so it must be set. The same behavior occurs when you set `init="custom"` and provide H and W with wrong shapes.

I wouldn't change this behavior. Instead we could probably improve the description of the W and H parameters to mention that their shapes must be in line with `n_components`. Would you like to submit a PR ?
As the given `H` already holds the information regarding the `n_components`, wouldn't it be preferred to set `n_components = H.shape[0]`?
this is especially true if the users haven't provided `n_components` themselves
Suppose you set `init="custom"` and provide W and H with shapes that don't match. Which one would you take ? I think the best solution is to raise an error in that situation. Another example: if you set `update_H=False` and set `n_components` but provide H with an non matching shape. I would also raise an error here.

`n_components=None` doesn't mean ignored, it just means `n_components=n_features`. I don't think it should generate a different behavior than setting any other value regarding matching shapes. What prevents you to set `n_components=H.shape[0]` ?
It seems I'm unable to convey the scenario to you:
If you enter `update_H=False` then you do not initiate neither H nor W (which is just taken as the average entry of `X`
Only in that scenario the n_components should be ignored, as the decomposition rank is decided by the dimensions of the given H
Please provide a minimal reproducible, causing the error, and what you expect to happen. Would make it easier to investigate.
reproducible code:
```
import numpy as np
from sklearn.decomposition import non_negative_factorization

W_true = np.random.rand(6, 2)
H_true = np.random.rand(2, 5)
X = np.dot(W_true, H_true)

W, H, n_iter = non_negative_factorization(X, H=H_true, update_H=False)
```

I get the error: 
```
Traceback (most recent call last):
  File "/Applications/miniconda3/envs/gep-dynamics/lib/python3.9/site-packages/IPython/core/interactiveshell.py", line 3460, in run_code
    exec(code_obj, self.user_global_ns, self.user_ns)
  File "<ipython-input-14-a8ac745879a9>", line 1, in <module>
    W, H, n_iter = non_negative_factorization(X, H=H_true, update_H=False)
  File "/Applications/miniconda3/envs/gep-dynamics/lib/python3.9/site-packages/sklearn/utils/_param_validation.py", line 192, in wrapper
    return func(*args, **kwargs)
  File "/Applications/miniconda3/envs/gep-dynamics/lib/python3.9/site-packages/sklearn/decomposition/_nmf.py", line 1111, in non_negative_factorization
    W, H, n_iter = est._fit_transform(X, W=W, H=H, update_H=update_H)
  File "/Applications/miniconda3/envs/gep-dynamics/lib/python3.9/site-packages/sklearn/decomposition/_nmf.py", line 1625, in _fit_transform
    W, H = self._check_w_h(X, W, H, update_H)
  File "/Applications/miniconda3/envs/gep-dynamics/lib/python3.9/site-packages/sklearn/decomposition/_nmf.py", line 1184, in _check_w_h
    _check_init(H, (self._n_components, n_features), "NMF (input H)")
  File "/Applications/miniconda3/envs/gep-dynamics/lib/python3.9/site-packages/sklearn/decomposition/_nmf.py", line 68, in _check_init
    raise ValueError(
ValueError: Array with wrong shape passed to NMF (input H). Expected (5, 5), but got (2, 5) 
```

The error is caused due to the wrong dimensions of `self._n_components`. The source of the wrong dimension is that `_fit_transform` calls `self._check_params(X)`, which doesn't see a value assinged to `self.n_components` sets `self._n_components = X.shape[1]`. The error can be avoided by providing the `n_components` argument.

The key point of my issue is that when `H` is provided by the user, then **clearly** the user means to have `H.shape[0]` components in the decomposition, and thus the `n_components` argument is redundant.
As I said, the default ``n_components=None`` doesn't mean unspecified n_components, but automatically set ``n_components=n_features``. When H is user provided, there's a check for constistency between ``n_components`` and ``H.shape[0]``. I think this is a desirable behavior, rather than having ``n_components=None`` to mean a different thing based on ``update_H`` being True or False. What prevents you from setting ``n_components=H.shape[0]`` ?
Diving into the code, i now see the issue has nothing to do with `update_H`. If a user provides either `W` or `H`, then `n_components` should be set accordingly. This is a completely different scenario then when neither of the both is provided, and users shouldn't have the need to specify n_components
What prevents you from setting ``n_components=H.shape[0]`` ?
I personally don't believe in giving a function the same information twice, and errors that don't make sense until you dive into the classes where the functions are defined.
If a user gives the data of the rank (implicitly in the dimensions of W/H), why make them give the same information again explicitly?
> errors that don't make sense until you dive into the classes where the functions are defined.

The error makes sense because `n_components=None` is documented as equivalent to `n_components=n_features`. Then it is expected that an error is raised if `W` or `H` doesn't have the appropriate shape, since it does not correspond to the requested `n_components`.

I'm not against changing the default to `n_components="auto"` (with a deprecation cycle) such that:
- if neither W or H are provided, it defaults to `n_features`
- if `H` is provided, it's inferred from `H`
- if `W` and `H` are provided, it's inferred from both and if their shape don't match, an error is raised
- in any case, if n_components != "auto" and `W` or `H` is provided, an error is raised if they don't match.
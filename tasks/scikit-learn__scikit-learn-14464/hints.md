`__init__` should only set the attributes, not modify or validate the
inputs. See our documentation. MyTransformA would not pass check_estimator.

If you mean that a Pipeline would not fit_predict with this issue, that is not the case. I ran into this problem with an end-to-end pipeline that kept returning random probas because of this issue.

This can (and does) cause silent errors that make Pipelines produce incorrect results in cross validation, while producing good results when fit directly. 

On the other hand, if you mean that this is a bad use of the class and that users should just "read the docs" I can accept that, but doesn't seem very much in the right spirit as there are so many users that use scikit as newbies. 

If useful I can produce an end-to-end example instead of a minimum one. 

This is clearly in violation of how we require the constructor to be
defined. It will not pass check_estimator.

I admit that we could be more verbose when something goes wrong here. As
far as I can tell, the issue is in get_params defaulting a parameter value
to None (
https://github.com/scikit-learn/scikit-learn/blob/7813f7efb5b2012412888b69e73d76f2df2b50b6/sklearn/base.py#L193).
I'll open a fix for this and see what other core devs think.

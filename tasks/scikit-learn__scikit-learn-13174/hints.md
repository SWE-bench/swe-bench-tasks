That could be applied to any meta-estimator that uses a base estimator, right?

Yes, it could be. I didn't have time when I wrote this issue to check the applicability to other ensembles.

Updated title and description

@jnothman I think that we have two options.
- Validate the input early as it is now and introduce a new parameter `check_input`  in `fit`, `predict`, etc with default vaule `True` in order to preserve the current behavior.  The `check_input` could be in the constrcutor.
- Relax the validation in the ensemble and let base estimator to handle the validation.

What do you think? I'll sent a PR.

IMO assuming the base estimator manages validation is fine.

Is this still open ? can I work on it?

@Chaitya62 I didn't have the time to work on this. So, go ahead.
@chkoar onit!
After reading code for 2 days and trying to understand what actually needs to be changed I figured out that in that a call to check_X_y is being made which is forcing X to be 2d now for the patch should I do what @chkoar  suggested ? 
As in let the base estimator handle validation? Yes, IMO

On 5 December 2016 at 06:46, Chaitya Shah <notifications@github.com> wrote:

> After reading code for 2 days and trying to understand what actually needs
> to be changed I figured out that in that a call to check_X_y is being made
> which is forcing X to be 2d now for the patch should I do what @chkoar
> <https://github.com/chkoar> suggested ?
>
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/7768#issuecomment-264726009>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz69Z4CUcCqOlkaOc0xpln9o1ovc85ks5rExiygaJpZM4KiQ_P>
> .
>

Cool I ll submit a PR soon 
@Chaitya62, Let me inform if you are not working on this anymore. I want to work on this. 
@devanshdalal I am working  on it have a minor  issue which I hope I ll soon solve
@Chaitya62 Are you still working on this?

@dalmia go ahead work on it I am not able to test my code properly

@Chaitya62 Thanks!
I'd like to work on this, if that's ok
As a first step, I tried looking at the behavior of meta-estimators when passed a 3D tensor. Looks like almost all meta-estimators which accept a base estimator fail :

```
>>> pytest -sx -k 'test_meta_estimators' sklearn/tests/test_common.py
<....>
AdaBoostClassifier raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data
AdaBoostRegressor raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data
BaggingClassifier raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data
BaggingRegressor raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data
ExtraTreesClassifier raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data
ExtraTreesRegressor raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data

Skipping GradientBoostingClassifier - 'base_estimator' key not supported
Skipping GradientBoostingRegressor - 'base_estimator' key not supported
IsolationForest raised error 'default contamination parameter 0.1 will change in version 0.22 to "auto". This will change the predict method behavior.' when parsing data   

RANSACRegressor raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data                                     
RandomForestClassifier raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data
RandomForestRegressor raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data
```
@jnothman @amueller considering this, should this be a WONTFIX, or should all the meta-estimators be fixed?
Thanks for looking into this. Not all ensembles are meta-estimators. Here
we intend things that should be generic enough to support non-scikit-learn
use-cases: not just dealing with rectangular feature matrices.

On Fri, 14 Sep 2018 at 08:23, Karthik Duddu <notifications@github.com>
wrote:

> As a first step, I tried looking at behavior of meta-estimators when
> passed a 3D tensor. Looks like almost all meta-estimators which accept a
> base estimator fail :
>
> >>> pytest -sx -k 'test_meta_estimators' sklearn/tests/test_common.py
> <....>
> AdaBoostClassifier raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data
> AdaBoostRegressor raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data
> BaggingClassifier raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data
> BaggingRegressor raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data
> ExtraTreesClassifier raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data
> ExtraTreesRegressor raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data
>
> Skipping GradientBoostingClassifier - 'base_estimator' key not supported
> Skipping GradientBoostingRegressor - 'base_estimator' key not supported
> IsolationForest raised error 'default contamination parameter 0.1 will change in version 0.22 to "auto". This will change the predict method behavior.' when parsing data
>
> RANSACRegressor raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data
> RandomForestClassifier raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data
> RandomForestRegressor raised error 'Found array with dim 3. Estimator expected <= 2.' when parsing data
>
> @jnothman <https://github.com/jnothman> @amueller
> <https://github.com/amueller> considering this, should this be a WONTFIX,
> or should all the meta-estimators be fixed?
>
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/7768#issuecomment-421171742>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz68Axs1khuYjm7lM4guYgyf2IlUL_ks5uatrDgaJpZM4KiQ_P>
> .
>

@jnothman  `Adaboost` tests are [testing](https://github.com/scikit-learn/scikit-learn/blob/ff28c42b192aa9aab8b61bc8a56b5ceb1170dec7/sklearn/ensemble/tests/test_weight_boosting.py#L323) the sparsity of the `X`. This means that we should skip these tests in order to relax the validation, right?
Sounds like it as long as it doesn't do other things with X than fit the
base estimator

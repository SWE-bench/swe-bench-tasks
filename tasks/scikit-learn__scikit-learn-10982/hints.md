I think it's safe enough to change this to a warning without a parameter.
There are too many parameters in any case, and the warning can be turned
into an error if the user wishes.

On 1 April 2018 at 16:34, James Ko <notifications@github.com> wrote:

> Description
>
> Instantiating RandomizedSearchCV with n_iter greater than the size of
> param_distributions (i.e. the product of the length of each
> distribution/array in the grid) will fail with an exception at this line
> <https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/model_selection/_search.py#L247>.
> This is a bit annoying for me because I have an app where I'm letting the
> user specify the number of iterations to run from the command line, also
> I've been fiddling around with the param grid so grid_size keeps
> changing. I don't want to have to work out the exact grid size when it goes
> below, say, 50; if I specify --n-iter 50 that should be interpreted as an
> upper bound on the number of iterations.
>
> Would it be possible to add an option (off by default) to the constructor
> specifying whether to throw in such cases? e.g. By passing
> allow_smaller_grid=True (the option would default to False)
>
> —
> You are receiving this because you are subscribed to this thread.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/10900>, or mute the
> thread
> <https://github.com/notifications/unsubscribe-auth/AAEz61unGMXrvJKZzsBUkx1jDwB_J7Ywks5tkHTYgaJpZM4TCu3C>
> .
>

PR welcome.​

Hi, I would like to claim this as my first issue. Do you have any advice on how to start/things to avoid?
We have contributor guidelines on our website. 
Understand the warnings module. Look for places in our test suite where we check that warnings are raised, and employ a similar idiom
@julietcl are you working on this PR or can I take it?
@maskani-moh I am working on it.
@julietcl It's all yours then! 😉 
I have replaced the relevant ValueError in _search.py with a warning, but when I test an example where grid_size < self.n_iter I get:
  File "sklearn/utils/_random.pyx", line 226, in sklearn.utils._random.sample_without_replacement
    
  File "sklearn/utils/_random.pyx", line 279, in sklearn.utils._random.sample_without_replacement
    not be randomized, see the method argument.
  File "sklearn/utils/_random.pyx", line 35, in sklearn.utils._random._sample_without_replacement_check_input
    
ValueError: n_population should be greater or equal than n_samples, got n_samples > n_population (6 > 4)

Should I change [this](https://github.com/scikit-learn/scikit-learn/blob/1de5b1ced23ad6a6e8e2d7bb1c50d36220bfa2d2/sklearn/utils/_random.pyx#L35) to a warning as well?
you should probably not change that, just change when/how you call it.​

Would something like this work?
```
if grid_size < self.n_iter:
       warnings.warn(
             'The total space of parameters %d is smaller '
             'than n_iter=%d. For exhaustive searches, use '
             'GridSearchCV.' % (grid_size, self.n_iter), RuntimeWarning)
       self.n_iter = grid_size
```
So that way for the use case described by op, if the grid size falls below the number of iterations a warning is issued and the number of iterations acts as an upper bound.
I think that is consistent with the current code for randomized search,
given its sampling without replacement approach.

On 16 April 2018 at 01:28, julietcl <notifications@github.com> wrote:

> Would something like this work?
> if grid_size < self.n_iter:
> warnings.warn(
> 'The total space of parameters %d is smaller '
> 'than n_iter=%d. For exhaustive searches, use '
> 'GridSearchCV.' % (grid_size, self.n_iter), RuntimeWarning)
> self.n_iter = grid_size
> So that way for the use case described by op, if the grid size falls below
> the number of iterations a warning is issued and the number of iterations
> acts as an upper bound.
>
> —
> You are receiving this because you commented.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/10900#issuecomment-381414923>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz6x_w_JEZU_uBwE5nydkSFCP74hGSks5to2cvgaJpZM4TCu3C>
> .
>

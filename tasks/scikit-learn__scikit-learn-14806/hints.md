That sounds reasonable to me, at least as an option and probably default
behaviour. But I don't think it's worth blocking release for that feature,
so if you want it in 0.21, offer a pull request soon? Ping @sergeyf

OK, I do pull request. Sorry iam a newby on github participation.
We keep the issue open until the issue is solved :)

Let us know if you need help.
Just making sure I understand this...

Would it work like this?

(1) Apply initial imputation to every single feature including _i_.
(2) Run the entire sequence of stored regressors while keeping feature _i_ fixed (`transform` only, no `fit`s).
(3) NEW: run a single fit/transform imputation for feature _i_.

Is that correct? If not, at what point would we fit/transform a single imputation of feature _i_?
Yes, exactly, that would be correct and the clean way. 

A fast correction could be (have not tested it), to make this part in [https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/impute.py](https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/impute.py ) optional:

Line 679 to 683:
```Python
        # if nothing is missing, just return the default
        # (should not happen at fit time because feat_ids would be excluded)
        missing_row_mask = mask_missing_values[:, feat_idx]
        if not np.any(missing_row_mask):
            return X_filled, estimator
```

Because the iterative process would not effect the feature i with respect to updated imputes. Don't making a special case should end up in the same result as the clean version you proposed @sergeyf .

Ah, I see what you're saying. Just keep fitting & storing the models but not doing any prediction. I don't see any obvious downsides here. Good idea, thanks.
Yes exactly, keep fitting but dont do predictions for features with no missing values.
Should i close and do a pull request or whats the process?
Leave this open, start a PR. Once a PR is merged, this ticket can be closed.

Thanks.
Or maybe we should consider making IterativeImputer experimental for this
release??

I don't really see this as a hugely important or common use case. It's good
to get right but it currently is reasonable if not perfect. What other
concerns do you have?

On Sat, May 4, 2019, 2:24 AM Joel Nothman <notifications@github.com> wrote:

> Or maybe we should consider making IterativeImputer experimental for this
> release??
>
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/13773#issuecomment-489310344>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAOJV3A4LM652TNRWY2VQRLPTVI6DANCNFSM4HKPSS4A>
> .
>

> Or maybe we should consider making IterativeImputer experimental for this release??

One possible reason might be linked with the default estimator, which I find slow to use it. Maybe, one cycle in experimental would allow to quickly change those if they are shown to be problematic in practice.
Let's do it. We have the mechanism, we're sure we've made design and implementation choices here that are not universal, so I'll open an issue
Pull request welcome to change the behaviour for features which are fully observed at training.
@jnothman do you want that by default or as a parameter? I feel like doing it by default might increase training time a lot if only a few features are actually missing in the data.
> @jnothman do you want that by default or as a parameter? I feel like doing it by default might increase training time a lot if only a few features are actually missing in the data.

I think it would be sensible to enable by default, but have the ability to disable it.
As someone who was confused enough by the current behavior to file a bug report, I too am in favor of making the new behavior a toggleable default!
Would you like to submit a fix as a pull request, @JackMiranda?
Or is @Pacman1984 still working on it?
It'd be nice to make progress on this

Maybe I can take a crack at this. 

To review: the change would be to (optionally and by default) to `fit` regressors on even those features that have no missing values at train time.

At `transform`, we can then impute them these features if they are missing for any sample. 

We will need a new test, and to update the doc string, Maybe the test can come directly from https://github.com/scikit-learn/scikit-learn/issues/14383?

Am I missing anything?
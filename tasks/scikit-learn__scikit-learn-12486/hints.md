Looks good in general, but you need to add a regression test (you could use the GMM one or just a classification one with a single class maybe)
Thanks for your feedback, will do it soon.

On Sat 29 Sep 2018 at 17:36, Andreas Mueller <notifications@github.com>
wrote:

> Looks good in general, but you need to add a regression test (you could
> use the GMM one or just a classification one with a single class maybe)
>
> —
> You are receiving this because you authored the thread.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/pull/12221#issuecomment-425677053>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AlCeRE4pCeU1nUuA-TSqV-sjZl8XJpiMks5uf-fagaJpZM4XAqk->
> .
>
-- 
*Alice MARTIN*
Data Scientist - Paris, France
adresse email pro: alice.martindonati.pro@gmail.com
https://www.linkedin.com/in/alicemartindonati
https://github.com/AMDonati

@AMDonati I am happy to get on a zoom or google hangouts meeting so we can run the checks.  Let me know what works for you.  My email:  reshama@wimlds.org

Updated to 0.17.1 and issue persists ( Changing GMM to GaussianMixture)

The error is strange, but GMM is not a supervised model, so AUC doesn't really make sense.
We might want to raise a better error, though it's hard to detect what's going on here in a sense.

Do you really mean updated to 0.17.1, not 0.18?

On 8 October 2016 at 03:28, Andreas Mueller notifications@github.com
wrote:

> The error is strange, but GMM is not a supervised model, so AUC doesn't
> really make sense.
> 
> —
> You are receiving this because you are subscribed to this thread.
> Reply to this email directly, view it on GitHub
> https://github.com/scikit-learn/scikit-learn/issues/7598#issuecomment-252298229,
> or mute the thread
> https://github.com/notifications/unsubscribe-auth/AAEz6_dNOBwzUCFpb4N1bNKGAjC02ZEDks5qxnMlgaJpZM4KRC_m
> .

Getting the same error with

```
    cv = GridSearchCV(
        estimator=DecisionTreeClassifier(),
        param_grid={
            'max_depth': [20],
            'class_weight': ['auto'],
            'min_samples_split': [100],
            'min_samples_leaf': [30],
            'criterion': ['gini']
        },
        scoring='roc_auc',
        n_jobs=-1,
    )
```

Log:

```
__call__(self=make_scorer(roc_auc_score, needs_threshold=True), clf=DecisionTreeClassifier(class_weight='auto', crit...resort=False, random_state=None, splitter='best'), X=memmap([[ 2.14686672e-01, 0.00000000e+00, 0...000000e+00, 1.00000000e+00, 0.00000000e+00]]), y=memmap([0, 0, 0, ..., 0, 0, 0]), sample_weight=None) 
170 
171 except (NotImplementedError, AttributeError): 
172 y_pred = clf.predict_proba(X) 
173 
174 if y_type == "binary": 
--> 175 y_pred = y_pred[:, 1] 
y_pred = array([[ 1.], 
[ 1.], 
[ 1.], 
..., 
[ 1.], 
[ 1.], 
[ 1.]]) 
176 elif isinstance(y_pred, list): 
177 y_pred = np.vstack([p[:, -1] for p in y_pred]).T 
178 
179 if sample_weight is not None: 

IndexError: index 1 is out of bounds for axis 1 with size 1 
```

It looks there like you might have been training your `DecisionTreeClassifier` on a single class... what does the `y` you pass to `GridSearchCV.fit` look like?

Yes, this error message is not very helpful.

I ran into this error and you are correct @amueller about the single class explanation. Here's what my data looks like.

```
X_test.shape: (750, 34)
y_test.shape: (750,)
y_test value_counts: True    750
```
So my data contains a single class: `True`.

Perhaps, a more descriptive error message would help. Something along the line of your comment: `It looks like you might have a single class`. Looking at line 175 long enough may give that away too.
Can someone help with this issue? I do not know how to fix it still.  Thank you!
clf = ExtraTreesClassifier()
my_cv = TimeSeriesSplit(n_splits=5)  # time series split

param_grid = {
              'n_estimators': [100, 300, 500, 700, 1000, 2000, 5000],
              'min_samples_split': [2, 5, 10],
              'min_samples_leaf': range(2,20,2),
              'bootstrap': [True, False]
             }

clf = GridSearchCV(estimator=clf, param_grid=param_grid, cv=my_cv, n_jobs=-1, scoring='roc_auc', return_train_score=False)
clf.fit(X, y)
@liuwanfei you likely have just one class in ```y```, at least looks like it was an issue for most people in this thread. It should be an error message with a clear text instead of the exception.
Yes, what the people above have mentioned is correct - if you train with one class you _will_ get this error.

However, if you have a look at my code, I generated a dataset which has 2 classes so that was not the case with me. What _was_ the causing the issue is that my param grid was set up with a subtle error.  Remember the "roc_auc" scorer is using probabilities as inputs to create the ROC curve, and in my example above, my parameter space for `n_components:` was `[1,2,3,4]`. 

If you think about it, a GMM with one component will output only one probability. Thus, the output of `model.predict_proba` will be a one dimensional array which is why an `IndexError` occurs on `pred[:, 1]`.

So, for your case, see if one of the parameter combinations might not result in the classifier being constrained to predicting a single class. 

P.S I only realised this _now_, almost 2 years after the post. lol
I and @reshamas are working on it
I guess we could do that as many people ask about it. I don't think there is that much of a point in doing that. Nearly all the models in scikit-learn are regularized, so this doesn't matter afaik.
I guess you are using a linear model?

@vighneshbirodkar is working on the `OneHotEncoder`, it might be worth waiting till that is finished.

Yup. I'm using a linear regression on categorical variables. So actually no regularization. 

The regression works fine so there must be a fix for collinearity (non invertibility) in `scipy.linalg.lstsq` but I find this way of building a model a bit confusing. The solution to the least squared problem with collinearity is under determined - there is a family of solutions. And so to solve it there is some behind the scenes choice being made as to _the_ solution which is hidden from the user. Basically I'd rather not introduce collinearity into a model that will then have to deal with that collinearity. 

This is all obviously just my under informed opinion :) 

Why are you not using regularization? I think the main reason people don't use regularization is that they want simple statistics on the coefficients. But scikit-learn doesn't provide any statistics of the coefficients. Maybe statsmodels would be a better fit for your application.

If you are interested in predictive performance, just replace `LinearRegression` with `RidgeCV` and your predictions will improve.

Ok. I guess regularization is the way to go in scikit-learn. I do still disagree in that I think dependence shouldn't be introduced into the model by way of preprocessors (or at least there should be an option to turn this off). But maybe this is getting at the difference between machine learning and statistical modelling. Or maybe who cares about independence if we have regularization.

Sorry for the slow reply. I'm ok with adding an option to turn this off. But as I said, OneHotEncoder is still being refactored.

I've elsewhere discussed similar for `LabelBinarizer` in the multiclass case, proposing the parameter name `drop_first` to ignore the encoding of the smallest value.
not sure if that was raise somewhere already. multicollinearity is really not a problem in any model in scikit-learn. But feel free to create a pull-request. The OneHotEncoder is being restructured quite heavily right now, though.

I'm interested in working on this feature! I ran into some problems using a OneHotEncoder in a pipeline that used a Keras Neural Network as the classifier. I was attempting to transform a few columns of categorical features into a dummy variable representation and feed the resulting columns (plus some numerical variables that were passed through) into the NN for classification. However, the one hot encoding played poorly with the collinear columns, and my model performed poorly out of sample. I was eventually able to design a workaround, but it seems to me that it would be valuable to have a tool in scikit-learn that could do this simply. 
I see the above pull request, which began to implement this in the DictVectorizer class, but it looks like this was never implemented (probably due to some unresolved fixes that were suggested). Is there anything stopping this from being implemented in the OneHotEncoder case instead?
I think we'd accept a PR. I'm a bit surprised there's none yet. We also changed the OneHotEncoder quite a bit recently. You probably don't want to modify the "legacy" mode. A question is whether/how we allow users to specify which category to drop. In regularized models this actually makes a difference IIRC.
We could have a parameter ``drop`` that's ``'none'`` by default, and could be ``'first'`` or a datastructure with the values to drop. could be a list/numpy array of length n_features (all input features are categorical in the new OneHotEncoder).
Reading through the comments on the old PR, I was thinking that those
options seem to be the natural choice. I'm in the midst of graduate school
applications right now so my time is somewhat limited, but this seems to be
something that is going to keep appearing in my work, so I'm going to have
to address this (or keep using workarounds) at some point.

On Wed, Nov 28, 2018 at 3:49 PM Andreas Mueller <notifications@github.com>
wrote:

> I think we'd accept a PR. I'm a bit surprised there's none yet. We also
> changed the OneHotEncoder quite a bit recently. You probably don't want to
> modify the "legacy" mode. A question is whether/how we allow users to
> specify which category to drop. In regularized models this actually makes a
> difference IIRC.
> We could have a parameter drop that's 'none' by default, and could be
> 'first' or a datastructure with the values to drop. could be a list/numpy
> array of length n_features (all input features are categorical in the new
> OneHotEncoder).
>
> —
> You are receiving this because you commented.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/6053#issuecomment-442599181>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/Am4ucQaSxhMTVGCeWx4cy-xx5Xl3EHmOks5uzvbugaJpZM4G2bMF>
> .
>

@jnothman are you happy with the changes I made? Feel free to leave additional comments if you find something that can be improved. I'm hoping to start working on some new bug fix as soon as this weekend.
I think you'd best adopt something like my approach. Imagine someone
analysing the most stable important features under control validation. If
the feature dropped differs for each cv split, the results are
uninterpretable

On 21 Jul 2017 6:43 am, "Gianluca Rossi" <notifications@github.com> wrote:

*@IamGianluca* commented on this pull request.
------------------------------

In sklearn/feature_extraction/dict_vectorizer.py
<https://github.com/scikit-learn/scikit-learn/pull/9361#discussion_r128625938>
:

>          for x in X:
             for f, v in six.iteritems(x):
                 if isinstance(v, six.string_types):
+                    if self.drop_first_category and f not in to_drop:

Hi Joel,

I like your solution! I've intentionally avoided splitting the string using
a separator to overcome issues of ambiguity ― I hope people don't ever use
the = character in columns names, but you never know :-) Let me know if you
want me to implement your suggestion, and I'll update my PR.

I also fear this is too sensitive to the ordering of the data for the user
to find it explicable.

That's a valid point. In my own project to overcome such problem, I've
stored the dictionaries that I want to pass to DictVectorizer inside a
"master" dictionary. This master dictionary has keys that can be sorted in
a way that guarantees the first category is deterministic.

x = vectorizer.fit_transform([v for k, v in sorted(master.items())])

In this example a key in master could be something like the following tuple:

(582498109, 'Desktop')

... where Desktop is the level I want to drop, and each id (the first
element in the tuple) is associated with multiple devices, such as Tablet,
Mobile, etc. I appreciate this is specific to my use case and not always
true.

To be entirely fair, as a Data Scientist, 99% of the times you don't really
care about which category is being dropped since that is simply your
baseline. I guess in those situations when you need a specific category to
be dropped, you can always build your own sorting function to pass to the
key argument in sorted.

What do you think?

—
You are receiving this because you were mentioned.

Reply to this email directly, view it on GitHub
<https://github.com/scikit-learn/scikit-learn/pull/9361#discussion_r128625938>,
or mute the thread
<https://github.com/notifications/unsubscribe-auth/AAEz6_FXTJlr9yn4TatzsLy6RkFc1lgfks5sP7vogaJpZM4OYxec>
.


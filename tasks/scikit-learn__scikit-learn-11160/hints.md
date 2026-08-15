We're not going to accept a Pandas dependency etc. But a dict-of-arrays
output might be appropriarte.

On 9 November 2016 at 12:42, Josh L. Espinoza notifications@github.com
wrote:

> Is it possible to add output options to http://scikit-learn.org/
> stable/modules/generated/sklearn.metrics.classification_report.html. It
> would be really useful to have a pd.DataFrame output or xr.DataArray
> output. Right now it outputs as a string that must be printed but it's
> difficult to use the results. I can make a quick helper script if that
> could be useful?
> 
> —
> You are receiving this because you are subscribed to this thread.
> Reply to this email directly, view it on GitHub
> https://github.com/scikit-learn/scikit-learn/issues/7845, or mute the
> thread
> https://github.com/notifications/unsubscribe-auth/AAEz6_2dK_NQXmu2GvaIYPqc4PpSmyfMks5q8SUegaJpZM4KtG75
> .

Sounds good to me.  I'll write something up tomorrow and send it over.

> On Nov 8, 2016, at 6:07 PM, Joel Nothman notifications@github.com wrote:
> 
> We're not going to accept a Pandas dependency etc. But a dict-of-arrays
> output might be appropriarte.
> 
> On 9 November 2016 at 12:42, Josh L. Espinoza notifications@github.com
> wrote:
> 
> > Is it possible to add output options to http://scikit-learn.org/
> > stable/modules/generated/sklearn.metrics.classification_report.html. It
> > would be really useful to have a pd.DataFrame output or xr.DataArray
> > output. Right now it outputs as a string that must be printed but it's
> > difficult to use the results. I can make a quick helper script if that
> > could be useful?
> > 
> > —
> > You are receiving this because you are subscribed to this thread.
> > Reply to this email directly, view it on GitHub
> > https://github.com/scikit-learn/scikit-learn/issues/7845, or mute the
> > thread
> > https://github.com/notifications/unsubscribe-auth/AAEz6_2dK_NQXmu2GvaIYPqc4PpSmyfMks5q8SUegaJpZM4KtG75
> > .
> > 
> > —
> > You are receiving this because you authored the thread.
> > Reply to this email directly, view it on GitHub, or mute the thread.

Hi, I would like to work on this issue. Can I go ahead with it?

This might not be the most elegant way but it works: 
```
from sklearn.metrics import classification_report
from collections import defaultdict

y_true = [0, 1, 2, 2, 2]
y_pred = [0, 0, 2, 2, 1]
target_names = ['class 0', 'class 1', 'class 2']

def report2dict(cr):
    # Parse rows
    tmp = list()
    for row in cr.split("\n"):
        parsed_row = [x for x in row.split("  ") if len(x) > 0]
        if len(parsed_row) > 0:
            tmp.append(parsed_row)
    
    # Store in dictionary
    measures = tmp[0]

    D_class_data = defaultdict(dict)
    for row in tmp[1:]:
        class_label = row[0]
        for j, m in enumerate(measures):
            D_class_data[class_label][m.strip()] = float(row[j + 1].strip())
    return D_class_data

report2dict(classification_report(y_true, y_pred, target_names=target_names))
# defaultdict(dict,
#             {'avg / total': {'f1-score': 0.61,
#               'precision': 0.7,
#               'recall': 0.6,
#               'support': 5.0},
#              'class 0': {'f1-score': 0.67,
#               'precision': 0.5,
#               'recall': 1.0,
#               'support': 1.0},
#              'class 1': {'f1-score': 0.0,
#               'precision': 0.0,
#               'recall': 0.0,
#               'support': 1.0},
#              'class 2': {'f1-score': 0.8,
#               'precision': 1.0,
#               'recall': 0.67,
#               'support': 3.0}})

pd.DataFrame(report2dict(classification_report(y_true, y_pred, target_names=target_names))).T
#              f1-score  precision  recall  support
# avg / total      0.61        0.7    0.60      5.0
# class 0          0.67        0.5    1.00      1.0
# class 1          0.00        0.0    0.00      1.0
# class 2          0.80        1.0    0.67      3.0
```
@jolespin Would it not be a better way to formulate a dict-of-arrays classification report while creating the classification report itself, in sklearn/metrics. Instead of having to convert an existing classification report.
Yes, that makes a lot more sense.  The code above was just a quick fix if somebody needed something temporary to convert the output into something indexable.  I don't have time to work on this but if you could take it over that would be awesome 👍 
@jnothman Shall I create a PR to add a dict-of-arrays output option to classification report?

Dict of dicts is okay too. Sure, let's see what others think of it once
it's in code.

On 21 January 2017 at 05:06, wazeerzulfikar <notifications@github.com>
wrote:

> @jnothman <https://github.com/jnothman> Shall I create a PR to add a
> dict-of-arrays output option to classification report?
>
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/7845#issuecomment-274138830>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz66xeI5ostMLCz7RLuCXC9GRjtXyjks5rUPeogaJpZM4KtG75>
> .
>

@jolespin thank you!
@jolespin thank you!
but, There seems to be a space in variable 'class_label'.
```
class_label = row[0].strip()
```
This works well.
Thank you!
Thanks for the PR. There's quite a backlog of reviewing to do, so please be patient!
Also, at a glance, I think this should be marked MRG: you intend no further work before review.
@jnothman  An assertion error is being raised in the travis build , but when running on my local machine the error is not raised. What could possibly be the reason for this?

Try, please, to simplify the implementation.

Formatting as string and then converting to float is not appropriate.
@wazeerzulfikar thank you for your work!
I see no further advancement has been made in the last 6 months.
@jnothman are there any plans to milestone this?
I don't think this is a roadmap-style feature. If someone submits a working, cleanly coded implementation, it will likely get merged, whenever that's done and reviewers are available.
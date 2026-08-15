Yes, I suppose such a setting would be useful.

On 6 January 2018 at 06:13, Ploy Temiyasathit <notifications@github.com>
wrote:

> Description
>
> I am not sure if it's intended for MultiLabelBinarizer to fit and
> transform only seen data or not.
>
> However, there are many times that it is not possible/not in our interest
> to know all of the classes that we're fitting at training time.
> For convenience, I am wondering if there should be another parameter that
> allows us to ignore the unseen classes by just setting them to 0?
> Proposed Modification
>
> Example:
>
> from sklearn.preprocessing import MultiLabelBinarizer
> mlb = MultiLabelBinarizer(ignore_unseen=True)
>
> y_train = [['a'],['a', 'b'], ['a', 'b', 'c']]
> mlb.fit(y_train)
>
> y_test = [['a'],['b'],['d']]
> mlb.transform(y_test)
>
> Result:
> array([[1, 0, 0],
> [0, 1, 0],
> [0, 0, 0]])
>
> (the current version 0.19.0 would say KeyError: 'd')
>
> I can open a PR for this if this is a desired behavior.
>
> Others also have similar issue:
> https://stackoverflow.com/questions/31503874/using-
> multilabelbinarizer-on-test-data-with-labels-not-in-the-training-set
>
> —
> You are receiving this because you are subscribed to this thread.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/10410>, or mute the
> thread
> <https://github.com/notifications/unsubscribe-auth/AAEz60OD_hPXjQlFF7Qus2WI5LT4pFtCks5tHnPzgaJpZM4RU1I5>
> .
>

The original poster stated they would like to submit a PR, so let's wait.

OK. I'm taking this then.
if no one is working, I'd like to take up this issue?
@mohdsanadzakirizvi looks like the OP said they will deliver
@mohdsanadzakirizvi Hey, sorry for not having much update recently. I've started working on it though, so I guess I will continue.
I think this will be easy to fix. The culprit is this line https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/linear_model/coordinate_descent.py#L715 which passes `copy=False`, instead of `copy=self.copy_X`. That'll probably fix the issue.

Thanks for reporting it.
Thanks for the diagnosis, @gxyd!
@jnothman, @gxyd: May I work on this?
go ahead

Thanks. On it!!
problem comes from this old PR:

https://github.com/scikit-learn/scikit-learn/pull/5133

basically we should now remove the "check_input=True" fit param from the objects now that we have the context manager to avoid slow checks.

see http://scikit-learn.org/stable/modules/generated/sklearn.config_context.html
I don't think the diagnosis is correct. The problem is that if you pass check_input=True, you bypass the check_input call that is meant to make the copy of X
Thanks for the additional clarifications @agramfort . Could you please  help reviewing [the PR](https://github.com/scikit-learn/scikit-learn/pull/10581)?
I think this will be easy to fix. The culprit is this line https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/linear_model/coordinate_descent.py#L715 which passes `copy=False`, instead of `copy=self.copy_X`. That'll probably fix the issue.

Thanks for reporting it.
Thanks for the diagnosis, @gxyd!
@jnothman, @gxyd: May I work on this?
go ahead

Thanks. On it!!
problem comes from this old PR:

https://github.com/scikit-learn/scikit-learn/pull/5133

basically we should now remove the "check_input=True" fit param from the objects now that we have the context manager to avoid slow checks.

see http://scikit-learn.org/stable/modules/generated/sklearn.config_context.html
I don't think the diagnosis is correct. The problem is that if you pass check_input=True, you bypass the check_input call that is meant to make the copy of X
Thanks for the additional clarifications @agramfort . Could you please  help reviewing [the PR](https://github.com/scikit-learn/scikit-learn/pull/10581)?
you need to add a non-regression test case that fails without this patch
and shows that we do not modify the data when told to copy.

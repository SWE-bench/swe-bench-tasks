Should we be deprecating and changing the `multioutput` used in RegressorMixin? How do we allow the user to select the new approach in a deprecation period?
@agramfort @ogrisel can you explain the rational behind this?
It looks to me like the behavior before the PR was exactly what we wanted an the PR broke the deprecation which requires us to do another deprecation cycle?
I vote +1 to deprecat and change the multioutput used in RegressorMixin. It seems misleading that r2_score and RegressorMixin have different defaults.
But yes, the deprecation is not easy. Maybe we can just warn and change the behavior after 2 versions.
And can someone tell me the difference between these two multioutput choices (e..g, why do you prefer uniform_average)? Seems that the deprecation is introduced in https://github.com/scikit-learn/scikit-learn/commit/1b1e10c3251bda9240f115123f6c17c8fde50e35 and I can't find relevant discussions.
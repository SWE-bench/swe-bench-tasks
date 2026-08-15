I think that we could consider that as a bug. We will have to add this parameter. Nowadays, I would find it easier just to pass a `SimpleImputer` instance.
@glemaitre 

Thanks for your suggestion:
> pass a SimpleImputer instance.

Here is what I tried:
`from sklearn.experimental import enable_iterative_imputer # noqa`
`from sklearn.impute import IterativeImputer`
`from sklearn.ensemble import HistGradientBoostingRegressor`
`from sklearn.impute import SimpleImputer`
`imputer = IterativeImputer(estimator=HistGradientBoostingRegressor(), initial_strategy=SimpleImputer(strategy="constant", fill_value=np.nan))`
`a = np.random.rand(200, 10)*np.random.choice([1, np.nan], size=(200, 10), p=(0.7, 0.3))`
`imputer.fit(a)`

However, I got the following error:
`ValueError: Can only use these strategies: ['mean', 'median', 'most_frequent', 'constant']  got strategy=SimpleImputer(fill_value=nan, strategy='constant')`
Which indicates that I cannot pass a `SimpleImputer` instance as `initial_strategy`.
It was a suggestion to be implemented in scikit-learn which is not available :)
@ValueInvestorThijs do you want to create a pull request that implements the option of passing an instance of an imputer as the value of `initial_strategy`?
@betatim I would love to. I’ll get started soon this week.
Unfortunately I am in an exam period, but as soon as I find time I will come back to this issue.
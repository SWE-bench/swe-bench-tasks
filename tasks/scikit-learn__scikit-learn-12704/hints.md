```python
ct = make_column_transformer((OneHotEncoder(sparse=False), cat_features),
                             remainder=StandardScaler())
```
i.e. the new attribute order, works, though.
But that means we botched the deprecation - in a case that I care about because it's now out there on paper ;)
Want me to check it, or is @jorisvandenbossche or somebody else on it?
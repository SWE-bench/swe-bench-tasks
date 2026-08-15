Can you please share a reproducible example that demonstrates the issue? I can't really figure out what you're talking about from this description.
Here's a self-contained example, using ``clustermap()``. This has to do with colors input for row/col colors that are pandas ``category`` dtype:
```python
import seaborn as sns; sns.set(color_codes=True)
iris = sns.load_dataset("iris")
species = iris.pop("species")
row_colors=species.map(dict(zip(species.unique(), "rbg")))
row_colors=row_colors.astype('category')
g = sns.clustermap(iris, row_colors=row_colors)
```

This raises the following error:
```
ValueError: fill value must be in categories
```
Thanks @MaozGelbart. It would still be helpful to understand the real-world case where the color annotations need to be categorical.
Same issue here